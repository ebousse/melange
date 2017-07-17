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
package fr.inria.diverse.melange.jvmmodel

import com.google.inject.Inject
import fr.inria.diverse.melange.ast.NamingHelper
import fr.inria.diverse.melange.metamodel.melange.ModelType
import java.util.Arrays
import java.util.Collections
import java.util.List
import org.eclipse.emf.common.util.Enumerator
import org.eclipse.emf.ecore.EEnum
import org.eclipse.xtext.common.types.JvmVisibility
import org.eclipse.xtext.xbase.jvmmodel.IJvmDeclaredTypeAcceptor
import org.eclipse.xtext.xbase.jvmmodel.JvmTypeReferenceBuilder
import org.eclipse.xtext.xbase.jvmmodel.JvmTypesBuilder

/**
 * @deprecated We now use EMF's generator for model types. This shouldn't be
 * used anymore.
 */
class EnumInferrer
{
	@Inject extension JvmTypesBuilder
	@Inject extension NamingHelper

	/**
	 * Mimic the EMF generator for EEnum.
	 * Clearly not a nice solution.
	 */
	def void generateEnum(
		ModelType mt,
		EEnum enu,
		IJvmDeclaredTypeAcceptor acceptor,
		extension JvmTypeReferenceBuilder builder
	) {
		acceptor.accept(mt.toEnumerationType(mt.getFqnFor(enu))[
			superTypes += Enumerator.typeRef

			// FIXME: Xtext's generator bug: should put an ";"
			//         if no literals
			enu.ELiterals.forEach[lit |
				members += mt.toEnumerationLiteral(lit.name.toUpperCase)[
					// FIXME
					//initializer = '''«lit.name.toUpperCase»(0, "A", "B")'''
				]

				members += mt.toField(lit.name.toUpperCase + "_VALUE", int.typeRef)[
					^static = true
					^final = true
					visibility = JvmVisibility::PUBLIC
					initializer = '''«lit.value»'''
				]
			]

			members += mt.toField("VALUES_ARRAY", it.typeRef.addArrayTypeDimension)[
				^static = true
				^final = true
				initializer = '''
					new «enu.name»[] {
						«FOR lit : enu.ELiterals»
						«lit.name.toUpperCase»,
						«ENDFOR»
					};
				'''
			]

			members += mt.toField("VALUES", List.typeRef(it.typeRef))[
				^static = true
				^final = true
				initializer = '''
					«Collections».unmodifiableList(«Arrays».asList(VALUES_ARRAY));
				'''
			]

			members += mt.toMethod("get", mt.getFqnFor(enu).typeRef)[
				^static = true
				parameters += mt.toParameter("literal", String.typeRef)
				body = '''
					for (int i = 0; i < VALUES_ARRAY.length; ++i) {
						«enu.name» result = VALUES_ARRAY[i];
						if (result.toString().equals(literal)) {
							return result;
						}
					}
					return null;
				'''
			]

			members += mt.toMethod("getByName", mt.getFqnFor(enu).typeRef)[
				^static = true
				parameters += mt.toParameter("name", String.typeRef)
				body = '''
					for (int i = 0; i < VALUES_ARRAY.length; ++i) {
						«enu.name» result = VALUES_ARRAY[i];
						if (result.getName().equals(name)) {
							return result;
						}
					}
					return null;
				'''
			]

			// FIXME
			members += mt.toMethod("get", mt.getFqnFor(enu).typeRef)[
				^static = true
				parameters += mt.toParameter("value", int.typeRef)
				val values = newArrayList
				body = '''
					switch (value) {
						«FOR lit : enu.ELiterals»
						«IF !values.contains(lit.value)»
						/* «values += lit.value» */
						case «lit.name.toUpperCase»_VALUE: return «lit.name.toUpperCase»;
						«ENDIF»
						«ENDFOR»
					}
					return null;
				'''
			]

			members += mt.toField("value", int.typeRef)[^final = true]
			members += mt.toField("name", String.typeRef)[^final = true]
			members += mt.toField("literal", String.typeRef)[^final = true]

			// FIXME
			members += mt.toConstructor[
				visibility = JvmVisibility::PRIVATE
				body = '''
					this.value = 0;
					this.name = "";
					this.literal = "";
				'''
			]

			members += mt.toConstructor[
				visibility = JvmVisibility::PRIVATE
				parameters += mt.toParameter("value", int.typeRef)
				parameters += mt.toParameter("name", String.typeRef)
				parameters += mt.toParameter("literal", String.typeRef)

				body = '''
					this.value = value;
					this.name = name;
					this.literal = literal;
				'''
			]

			members += mt.toMethod("getName", String.typeRef)[
				body = '''return name;'''
			]

			members += mt.toMethod("getValue", int.typeRef)[
				body = '''return value;'''
			]

			members += mt.toMethod("getLiteral", String.typeRef)[
				body = '''return literal;'''
			]

			members += mt.toMethod("toString", String.typeRef)[
				body = '''return literal;'''
			]
		])
	}
}
