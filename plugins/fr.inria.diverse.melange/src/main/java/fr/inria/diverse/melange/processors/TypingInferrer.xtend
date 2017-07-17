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
package fr.inria.diverse.melange.processors

import com.google.inject.Inject
import fr.inria.diverse.melange.ast.ASTHelper
import fr.inria.diverse.melange.ast.LanguageExtensions
import fr.inria.diverse.melange.ast.ModelTypeExtensions
import fr.inria.diverse.melange.metamodel.melange.MelangeFactory
import fr.inria.diverse.melange.metamodel.melange.ModelTypingSpace
import fr.inria.diverse.melange.typesystem.MelangeTypesRegistry
import org.eclipse.xtext.naming.IQualifiedNameProvider

/**
 * Computes the subtyping hierarchy among {@link ModelType}s and the
 * implementation relations between {@link Language}s and {@link ModelType}s.
 * Populates the #implements and #subtypingRelations references accordingly.
 * Also populates the {@link MelangeTypesRegistry} that is used in our
 * specialized Xbase model-oriented type system and compiler.
 */
class TypingInferrer extends DispatchMelangeProcessor
{
	@Inject extension ASTHelper
	@Inject extension ModelTypeExtensions
	@Inject extension IQualifiedNameProvider
	@Inject extension LanguageExtensions
	@Inject MelangeTypesRegistry typesRegistry

	def dispatch void preProcess(ModelTypingSpace root, boolean preLinkingPhase) {
		typesRegistry.clear

		val externalRoots = root
			.languages
			.map[allDependencies]
			.flatten
			.map[eContainer]
			.filter(ModelTypingSpace)
			.filter[it !== root]
			.toSet
		val allMts = externalRoots.map[modelTypes].flatten.toList
		allMts.addAll(root.modelTypes)
		
		allMts
		.filter[isComparable]
		.forEach[mt1 |
			allMts
			.filter[mt2 |
				   mt2 != mt1
				&& !mt1.subtypingRelations.exists[superType.name == mt2.name]
				&& mt1.isSubtypeOf(mt2)
			]
			.forEach[mt2 |
				mt1.subtypingRelations +=
					MelangeFactory.eINSTANCE.createSubtyping => [
						subType = mt1
						superType = mt2
					]

				typesRegistry.registerSubtyping(
					mt1.fullyQualifiedName.toString, mt2)
			]

			root.languages
			.filter[l |
				   l.isTypable
				&& !l.^implements.exists[name == mt1.name]
				&& l.doesImplement(mt1)
			]
			.forEach[l |
				l.^implements += mt1

				typesRegistry.registerImplementation(
					l.fullyQualifiedName.toString, mt1)
			]
		]
	}

	def dispatch void postProcess(ModelTypingSpace root) {
		root.languages.forEach[^implements.clear]
		root.modelTypes.forEach[subtypingRelations.clear]
	}
}
