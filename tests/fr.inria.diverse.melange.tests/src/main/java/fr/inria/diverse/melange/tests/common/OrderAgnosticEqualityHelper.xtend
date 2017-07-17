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

import org.eclipse.emf.ecore.EObject
import org.eclipse.emf.ecore.util.EcoreUtil

import java.util.ArrayList
import java.util.Comparator
import java.util.Collections
import java.util.List

class OrderAgnosticEObjectComparator implements Comparator<EObject>
{
	override compare(EObject o1, EObject o2) {
		val s1 = extractComparisonString(o1)
		val s2 = extractComparisonString(o2)

		return s1.compareTo(s2)
	}

	private def extractComparisonString(EObject o) {
		return o.toString.replaceAll(o.class.name, "").replaceAll(Integer.toHexString(o.hashCode), "")
	}
}

class OrderAgnosticEqualityHelper extends EcoreUtil$EqualityHelper
{
	override equals(List<EObject> l1, List<EObject> l2) {
		val comparator = new OrderAgnosticEObjectComparator
		val ll1 = new ArrayList<EObject>(l1)
		val ll2 = new ArrayList<EObject>(l2)

		Collections.sort(ll1, comparator)
		Collections.sort(ll2, comparator)

		return super.equals(ll1, ll2)
	}
}
