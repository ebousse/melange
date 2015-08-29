package fr.inria.diverse.melange.ui.builder

import com.google.inject.Inject
import com.google.inject.Provider
import fr.inria.diverse.melange.ast.LanguageExtensions
import fr.inria.diverse.melange.ast.MetamodelExtensions
import fr.inria.diverse.melange.ast.ModelTypeExtensions
import fr.inria.diverse.melange.ast.ModelingElementExtensions
import fr.inria.diverse.melange.eclipse.EclipseProjectHelper
import fr.inria.diverse.melange.lib.EcoreExtensions
import fr.inria.diverse.melange.metamodel.melange.Language
import fr.inria.diverse.melange.metamodel.melange.ModelType
import fr.inria.diverse.melange.metamodel.melange.ModelTypingSpace
import fr.inria.diverse.melange.processors.ExtensionPointProcessor
import fr.inria.diverse.melange.resource.MelangeDerivedStateComputer
import org.apache.log4j.Logger
import org.eclipse.core.resources.IProject
import org.eclipse.core.resources.ResourcesPlugin
import org.eclipse.core.runtime.IProgressMonitor
import org.eclipse.core.runtime.OperationCanceledException
import org.eclipse.core.runtime.SubProgressMonitor
import org.eclipse.core.runtime.jobs.Job
import org.eclipse.emf.ecore.EPackage
import org.eclipse.emf.ecore.resource.Resource
import org.eclipse.xtext.builder.EclipseResourceFileSystemAccess2
import org.eclipse.xtext.generator.IGenerator
import org.eclipse.xtext.generator.OutputConfigurationProvider
import org.eclipse.xtext.resource.DerivedStateAwareResource

class MelangeBuilder
{
	@Inject IGenerator generator
	@Inject MelangeDerivedStateComputer computer
	@Inject Provider<EclipseResourceFileSystemAccess2> fileSystemAccessProvider
	@Inject OutputConfigurationProvider outputProvider
	@Inject EclipseProjectHelper eclipseHelper
	@Inject ExtensionPointProcessor extensionProcessor
	@Inject extension LanguageExtensions
	@Inject extension MetamodelExtensions
	@Inject extension ModelingElementExtensions
	@Inject extension ModelTypeExtensions
	@Inject extension EcoreExtensions
	static final Logger log = Logger.getLogger(MelangeBuilder)

	def void generateAll(Resource res, IProject project, IProgressMonitor monitor) {
		cleanAll(res, project, new SubProgressMonitor(monitor, 1))
		generateInterfaces(res, project, new SubProgressMonitor(monitor, 1))
		generateLanguages(res, project, new SubProgressMonitor(monitor, 1))
		generateAdapters(res, project, new SubProgressMonitor(monitor, 1))
		generatePluginXml(res, project, new SubProgressMonitor(monitor, 1))
	}

	def void generateInterfaces(Resource res, IProject project, IProgressMonitor monitor) {
		val root = res.contents.head as ModelTypingSpace
		val mts = root.elements.filter(ModelType)

		monitor.beginTask("Generating interfaces", mts.size)

		cleanInterfaces(res, project, monitor)
		mts.forEach[mt |
			if (monitor.canceled)
				throw new OperationCanceledException

			val ecoreUri = '''platform:/resource/«project.name»/model-gen/«mt.name».ecore'''

			log.debug('''Registering new EPackage for «mt.name» in EMF registry''')
			if (!EPackage.Registry.INSTANCE.containsKey(mt.pkgs.head.nsURI))
				EPackage.Registry.INSTANCE.put(mt.pkgs.head.nsURI, mt.pkgs.head)

			log.debug('''Serializing Ecore interface description for «mt.name» in «ecoreUri»''')
			mt.createEcore(ecoreUri, mt.uri)
			monitor.worked(1)
		]
	}

	def void generateLanguages(Resource res, IProject project, IProgressMonitor monitor) {
		val root = res.contents.head as ModelTypingSpace
		val toGenerate = root.elements.filter(Language).filter[generatedByMelange]

		monitor.beginTask("Generating EMF runtime for languages", toGenerate.size)

		cleanLanguages(res, project, monitor)
		toGenerate.forEach[l |
			if (monitor.canceled)
				throw new OperationCanceledException

			eclipseHelper.createEMFRuntimeProject(l.externalRuntimeName, l)
			l.createExternalEcore
			l.createExternalGenmodel
			l.syntax.genmodels.head.generateCode
			l.createExternalAspects
			eclipseHelper.addDependencies(project, #[l.externalRuntimeName])
			monitor.worked(1)
		]
	}

	def void generateAdapters(Resource res, IProject project, IProgressMonitor monitor) {
		val fsa = fileSystemAccessProvider.get => [f |
			f.monitor = monitor
			f.project = project
		]

		outputProvider.outputConfigurations.forEach [
			fsa.outputConfigurations.put(name, it)
		]

		cleanAdapters(res, project, monitor)

		if (res instanceof DerivedStateAwareResource) {
			computer.inferFullDerivedState(res)
			generator.doGenerate(res, fsa)
		}
	}

	def void generatePluginXml(Resource res, IProject project, IProgressMonitor monitor) {
		val root = res.contents.head as ModelTypingSpace
		extensionProcessor.preProcess(root, false)
	}

	/**
	 * - Clean the src-gen/ and model-gen/ folders of the current project
	 * - For each language generated by Melange, delete its associated projects
	 * - Remove the dangling dependencies from the current project
	 */
	def void cleanAll(Resource res, IProject project, IProgressMonitor monitor) {
		cleanAdapters(res, project, monitor)
		cleanInterfaces(res, project, monitor)
		cleanLanguages(res, project, monitor)
	}

	def void cleanLanguages(Resource res, IProject project, IProgressMonitor monitor) {
		val root = res.contents.head as ModelTypingSpace
		val danglingBundles = newArrayList

		root.elements
		.filter(Language)
		.filter[generatedByMelange]
		.forEach[l |
			val runtimeName = l.externalRuntimeName
			val runtimeProject = project.workspace.root.getProject(runtimeName)
			runtimeProject.delete(true, true, monitor)
			danglingBundles += runtimeName
		]

		eclipseHelper.removeDependencies(project, danglingBundles)
	}

	def void cleanInterfaces(Resource res, IProject project, IProgressMonitor monitor) {
		val modelGenFolder = project.getFolder("model-gen/")

		if (modelGenFolder.exists)
			modelGenFolder.members.forEach[delete(true, monitor)]
	}

	def void cleanAdapters(Resource res, IProject project, IProgressMonitor monitor) {
		val srcGenFolder = project.getFolder("src-gen/")

		if (srcGenFolder.exists)
			srcGenFolder.members.forEach[delete(true, monitor)]
	}

	private def void waitForAutoBuild() {
		var wasInterrupted = false
		do {
			try {
				Job.jobManager.join(ResourcesPlugin::FAMILY_AUTO_BUILD,	null)
				wasInterrupted = false
			} catch (OperationCanceledException e) {
				e.printStackTrace
			} catch (InterruptedException e) {
				wasInterrupted = true
			}
		} while (wasInterrupted)
	}
}
