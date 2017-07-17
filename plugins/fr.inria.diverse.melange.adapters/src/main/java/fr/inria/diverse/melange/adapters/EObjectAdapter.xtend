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
package fr.inria.diverse.melange.adapters

import org.eclipse.emf.common.util.AbstractTreeIterator
import org.eclipse.emf.ecore.EObject
import org.eclipse.emf.ecore.impl.BasicEObjectImpl
import org.eclipse.emf.ecore.impl.EObjectImpl
import org.eclipse.emf.ecore.resource.Resource
import org.eclipse.emf.ecore.util.BasicInternalEList

/**
 * Adapter delegation pattern for manipulating an {@link EObject} through the
 * interface of another {@link EObject}.
 * Delegates adapters creation to the appropriate
 * {@link AdaptersFactory adapter factory}.   
 */
abstract class EObjectAdapter<E extends EObject> extends EObjectImpl implements EObject, GenericAdapter<E>
{
	protected E adaptee
	protected Resource eResource
	protected AdaptersFactory adaptersFactory

	new(AdaptersFactory factory) {
		adaptersFactory = factory
	}

	def void setResource(Resource res) {
		eResource = res
	}

	override eResource() {
		return eResource
	}

	override getAdaptee() { return adaptee }
	override setAdaptee(E a) { adaptee = a }

	override eContainer() {
		return adaptersFactory.createAdapter(adaptee.eContainer, eResource)
	}

	override eInternalContainer() {
		return adaptersFactory.createAdapter(adaptee.eContainer, eResource)
	}

	override eContainerFeatureID() {
		return (adaptee as BasicEObjectImpl).eContainerFeatureID
	}

	override eContents() {
		val ret = new BasicInternalEList<EObject>(EObject) ;

		adaptee.eContents.forEach[o |
			ret += adaptersFactory.createAdapter(o, eResource) ?: o
		]

		return ret
	}

	override eAllContents() {
		return
			new AbstractTreeIterator<EObject>(this, false) {
				override getChildren(Object object) {
					return (object as EObject).eContents.iterator
				}
			}
	}

	override eAdapters() {
		return adaptee.eAdapters
	}

	override toString() {
		return '''Adap<«class.name»>@«Integer::toHexString(hashCode)»(«adaptee»)'''
	}

//	override eCrossReferences() {
//		throw new UnsupportedOperationException("TODO: Adaptation needed here")
//	}
//
//	override eInvoke(EOperation operation, EList<?> arguments) throws InvocationTargetException {
//		throw new UnsupportedOperationException("TODO: Adaptation needed here")
//	}
}
