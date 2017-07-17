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
package fr.inria.diverse.melange.ui.preferences

import fr.inria.diverse.melange.ui.internal.MelangeActivator
import fr.inria.diverse.melange.preferences.MelangePreferencesConstants
import org.eclipse.jface.preference.BooleanFieldEditor
import org.eclipse.swt.SWT
import org.eclipse.swt.layout.GridData
import org.eclipse.swt.layout.GridLayout
import org.eclipse.swt.widgets.Composite
import org.eclipse.swt.widgets.Group
import org.eclipse.ui.IWorkbench
import org.eclipse.xtext.ui.editor.preferences.LanguageRootPreferencePage

class MelangePreferencePage extends LanguageRootPreferencePage
{
	override init(IWorkbench workbench) {
		setPreferenceStore(MelangeActivator.instance.preferenceStore)
	}

	override createFieldEditors() {
		val parent = fieldEditorParent
		val group = new Group(parent, SWT.SHADOW_IN) => [
			text = "Generation"
			layoutData = new GridData(SWT.FILL, SWT.TOP, true, false)
			layout = new GridLayout(1, false)
		]

		val composite = new Composite(group, SWT.NONE)

		addField(
			new BooleanFieldEditor(
				MelangePreferencesConstants.GENERATE_ADAPTERS_CODE,
				"Always generate adapters code",
				composite
			)
		)

		group.pack
	}
}
