/*******************************************************************************
 * Copyright (c) 2017 Inria and others.
 * All rights reserved. This program and the accompanying materials
 * are made available under the terms of the Eclipse Public License v1.0
 * which accompanies this distribution, and is available at
 * http://www.eclipse.org/legal/epl-v10.html
 *
 * Contributors:
 *     Inria - initial API and implementation
 *******************************************************************************/
package fr.inria.diverse.melange.tests.common

import fr.inria.diverse.melange.ast.ModelingElementExtensions
import fr.inria.diverse.melange.lib.EcoreExtensions
import fr.inria.diverse.melange.metamodel.melange.Language
import fr.inria.diverse.melange.metamodel.melange.ModelType
import fr.inria.diverse.melange.metamodel.melange.ModelTypingSpace
import fr.inria.diverse.melange.metamodel.melange.ModelingElement
import fr.inria.diverse.melange.metamodel.melange.Transformation
import java.io.IOException
import java.util.List
import javax.inject.Inject
import org.eclipse.emf.common.util.Diagnostic
import org.eclipse.emf.common.util.URI
import org.eclipse.emf.compare.EMFCompare
import org.eclipse.emf.compare.Match
import org.eclipse.emf.compare.diff.DefaultDiffEngine
import org.eclipse.emf.compare.diff.FeatureFilter
import org.eclipse.emf.compare.scope.DefaultComparisonScope
import org.eclipse.emf.ecore.EObject
import org.eclipse.emf.ecore.EPackage
import org.eclipse.emf.ecore.EReference
import org.eclipse.emf.ecore.EStructuralFeature
import org.eclipse.emf.ecore.ETypedElement
import org.eclipse.emf.ecore.EcorePackage
import org.eclipse.emf.ecore.resource.Resource
import org.eclipse.emf.ecore.resource.impl.ResourceSetImpl
import org.eclipse.emf.ecore.util.Diagnostician
import org.eclipse.xtext.util.IAcceptor
import org.eclipse.xtext.xbase.compiler.CompilationTestHelper
import org.eclipse.xtext.xbase.compiler.CompilationTestHelper.Result
import org.junit.Assert

class MelangeTestHelper
{
	@Inject extension EcoreExtensions
	@Inject extension CompilationTestHelper
	@Inject extension ModelingElementExtensions

	def Language l(ModelTypingSpace root, String languageName) {
		return root.elements.filter(Language).findFirst[name == languageName]
	}

	def ModelType mt(ModelTypingSpace root, String mtName) {
		return root.elements.filter(ModelType).findFirst[name == mtName]
	}

	def Transformation t(ModelTypingSpace root, String tName) {
		return root.elements.filter(Transformation).findFirst[name == tName]
	}

	def void initialize(Result res, String cls) {
		val String[] p = null

		try {
			res.getCompiledClass(cls)?.getMethod("main", typeof(String[]))?.invoke(null, p as Object)
		} catch (Exception e) {
			// ...
		}
	}

	def <T> T invokeTransfo(Result res, String cls) {
		try {
			return res.getCompiledClass(cls)?.getMethod("call", null)?.invoke(null, null) as T
		} catch (Exception e) {
			// ...
		}
	}

	def <T> T invokeTransfo(Result res, String cls, List<String> pTypes, List<Object> pValues) {
		try {
			return res.getCompiledClass(cls)?.getMethod("call", pTypes.map[res.getCompiledClass(it)])?.invoke(null, pValues?.toArray) as T
		} catch (Exception e) {
			// ...
		}
	}

	def void assertCompilesTo(CharSequence source, String filename, CharSequence expected) throws IOException {
		compile(source, new IAcceptor<CompilationTestHelper.Result>() {
			override void accept(Result r) {
				Assert.assertEquals(expected.toString, r.getGeneratedCode(filename))
			}
		})
	}

	def void assertGeneratedCodeContains(CharSequence source, String filename, CharSequence expected) throws IOException {
		compile(source, new IAcceptor<CompilationTestHelper.Result>() {
			override void accept(Result r) {
				Assert.assertTrue(r.getGeneratedCode(filename).contains(expected.toString))
			}
		})
	}

	def void assertImplements(Language l, ModelType mt) {
		Assert.assertTrue(l.implements.contains(mt))
	}

	def dispatch void assertIsValid(Resource res) {
		assertIsValid(res.contents.head)
	}

	def dispatch void assertIsValid(EObject obj) {
		val diagnostic = Diagnostician.INSTANCE.validate(obj)
		Assert.assertTrue(
			diagnostic.toString,
			diagnostic.severity == Diagnostic.OK
		)
	}

	def void assertMatch(EPackage pkg, String refEcore) {
		val rs = new ResourceSetImpl
		val uri = URI::createURI(refEcore)
		val res = rs.getResource(uri, true)
		val ref = res.contents.head as EPackage

		assertMatch(pkg, ref)
	}

	def void assertMatch(EPackage pkg, EPackage ref) {
		val scope = new DefaultComparisonScope(pkg, ref, null)
		// We don't want to take order into account
		// We don't want to take eAnnotations into account
		val comparison = EMFCompare.builder().setDiffEngine(
			new DefaultDiffEngine() {
				override def FeatureFilter createFeatureFilter() {
					return new FeatureFilter() {
						override boolean isIgnoredReference(Match match, EReference ref) {
							return ref == EcorePackage.Literals.EMODEL_ELEMENT__EANNOTATIONS
							        || super.isIgnoredReference(match, ref)
						}

						override boolean checkForOrderingChanges(EStructuralFeature f) {
							return false
						}
					}
				}
			}
		).build.compare(scope)

		if (!comparison.differences.empty) {
			println(comparison.differences.join("\n"))
			Assert.fail(comparison.differences.join(", "))
		}

		Assert.assertTrue(comparison.differences.empty)
	}

	def EObject getEObject(ModelingElement m, String path) {
		val segments = path.split("/")
		val pkg_ = segments.get(0)
		val cls_ = segments.get(1)
		val feature_ = segments.get(2)

		val pkg = m.pkgs.findFirst[name == pkg_]

		if (pkg === null)
			return null

		val cls = pkg.findClass(cls_)

		if (cls === null || feature_ === null)
			return cls

		val feature =
			switch (feature_) {
				case feature_.startsWith("@"):
					cls.EOperations.findFirst[name == feature_.substring(1)]
				case feature_.startsWith("#"):
					cls.EAttributes.findFirst[name == feature_.substring(1)]
				case feature_.startsWith("-"):
					cls.EReferences.findFirst[name == feature_.substring(1)]
			}

		return feature
	}

	/**
	 * Dummy path-matching for EObjects
	 *
	 * pkg/MyCls/(#attr | @op | -ref)[type]
	 */
	def void assertEObjectExists(Language l, String path) {
		val type = path.substring(path.indexOf("["), path.length - 1)
		val obj = l.syntax.getEObject(path.substring(0, path.indexOf("[")))
		Assert.assertNotNull("Cannot find " + path + " in " + l.name, obj)
		Assert.assertEquals(obj + " is not of type " + type, type, (obj as ETypedElement).EType.name)
	}

	def void assertEObjectExists(ModelType mt, String path) {
		val type = path.substring(path.indexOf("[") + 1, path.length - 1)
		val obj = mt.getEObject(path.substring(0, path.indexOf("[")))
		val objType = (obj as ETypedElement).EType?.name
		Assert.assertNotNull("Cannot find " + path + " in " + mt.name, obj)
		if (!(objType === null && type == "void"))
			Assert.assertEquals(obj + " is not of type " + type, type, objType)
	}
}
