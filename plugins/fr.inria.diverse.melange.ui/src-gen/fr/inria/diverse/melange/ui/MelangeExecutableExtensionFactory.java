/*
 * generated by Xtext
 */
package fr.inria.diverse.melange.ui;

import org.eclipse.xtext.ui.guice.AbstractGuiceAwareExecutableExtensionFactory;
import org.osgi.framework.Bundle;

import com.google.inject.Injector;

import fr.inria.diverse.melange.ui.internal.MelangeActivator;

/**
 * This class was generated. Customizations should only happen in a newly
 * introduced subclass. 
 */
public class MelangeExecutableExtensionFactory extends AbstractGuiceAwareExecutableExtensionFactory {

	@Override
	protected Bundle getBundle() {
		return MelangeActivator.getInstance().getBundle();
	}
	
	@Override
	protected Injector getInjector() {
		return MelangeActivator.getInstance().getInjector(MelangeActivator.FR_INRIA_DIVERSE_MELANGE_MELANGE);
	}
	
}
