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
package inheritanceoverriding

import fr.inria.diverse.k3.al.annotationprocessor.Aspect

@Aspect(className = fsm.FSM)
class A1 {
	public int i1
	def void f1() {}
}

@Aspect(className = fsm.State)
class B1 {
	public int i2
	def void f2() {}
}

@Aspect(className = fsm.Transition)
class C1 {
	public int i3
	def void f3() {}
}

@Aspect(className = fsm.FSM)
class A2 {
	public int i4
	def void f4() {}
}

@Aspect(className = fsm.State)
class B2 {
	public int i5
	def void f5() {}
}

@Aspect(className = fsm.Transition)
class C2 {
	public int i6
	def void f6() {}
}

@Aspect(className = fsm.FSM)
class OverrideA1 {
	def void f1() {}
}
