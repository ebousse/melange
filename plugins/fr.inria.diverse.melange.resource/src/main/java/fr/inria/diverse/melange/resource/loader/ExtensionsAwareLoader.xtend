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
package fr.inria.diverse.melange.resource.loader

import org.eclipse.emf.ecore.resource.Resource
import org.eclipse.emf.ecore.EPackage

interface ExtensionsAwareLoader
{
	def void     initialize(EPackage base, EPackage extended)

	def Resource loadExtendedAsBase(String uri, boolean loadOnDemand) throws PackageCompatibilityException
	def Resource loadBaseAsExtended(String uri, boolean loadOnDemand) throws PackageCompatibilityException
}

class PackageCompatibilityException extends Exception
{
	new(String msg) {
		super(msg)
	}
}
