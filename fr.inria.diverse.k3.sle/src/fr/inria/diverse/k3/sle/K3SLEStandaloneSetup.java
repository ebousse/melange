/*
* generated by Xtext
*/
package fr.inria.diverse.k3.sle;

/**
 * Initialization support for running Xtext languages 
 * without equinox extension registry
 */
public class K3SLEStandaloneSetup extends K3SLEStandaloneSetupGenerated{

	public static void doSetup() {
		new K3SLEStandaloneSetup().createInjectorAndDoEMFRegistration();
	}
}

