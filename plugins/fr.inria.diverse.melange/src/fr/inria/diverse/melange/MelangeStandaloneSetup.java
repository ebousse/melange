/*
 * generated by Xtext
 */
package fr.inria.diverse.melange;

/**
 * Initialization support for running Xtext languages 
 * without equinox extension registry
 */
public class MelangeStandaloneSetup extends MelangeStandaloneSetupGenerated{

	public static void doSetup() {
		new MelangeStandaloneSetup().createInjectorAndDoEMFRegistration();
	}
}

