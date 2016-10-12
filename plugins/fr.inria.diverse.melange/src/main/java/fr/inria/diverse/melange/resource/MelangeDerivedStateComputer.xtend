package fr.inria.diverse.melange.resource

import com.google.inject.Inject
import fr.inria.diverse.melange.jvmmodel.JvmModelInferrerHelper
import fr.inria.diverse.melange.jvmmodel.MelangeTypesBuilder
import fr.inria.diverse.melange.metamodel.melange.ModelTypingSpace
import fr.inria.diverse.melange.metamodel.melange.Transformation
import fr.inria.diverse.melange.processors.ExactTypeInferrer
import fr.inria.diverse.melange.processors.LanguageProcessor
import fr.inria.diverse.melange.processors.MelangeProcessor
import fr.inria.diverse.melange.processors.TypingInferrer
import fr.inria.diverse.melange.processors.WildcardAspectResolver
import fr.inria.diverse.melange.utils.EPackageProvider
import java.util.List
import org.apache.log4j.Logger
import org.eclipse.emf.ecore.xml.namespace.XMLNamespacePackage
import org.eclipse.xtext.resource.DerivedStateAwareResource
import org.eclipse.xtext.util.internal.Stopwatches
import org.eclipse.xtext.xbase.jvmmodel.JvmModelAssociator

import static org.eclipse.xtext.util.internal.Stopwatches.*

/**
 * A specialized {@link JvmModelAssociator} that is basically the entry point
 * for all the Melange process.
 * <br>
 * We first retrieve the just-parsed {@link DerivedStateAwareResource},
 * initialize the stopwatches, apply a set of pre-processors that transforms
 * the parsed AST before code generation and set the context of inferrers
 * before calling them.
 */
class MelangeDerivedStateComputer extends JvmModelAssociator
{
	@Inject MelangeTypesBuilder builder
	@Inject JvmModelInferrerHelper helper
	@Inject EPackageProvider provider
	List<MelangeProcessor> processors = newArrayList

	private static final Logger log = Logger.getLogger(MelangeDerivedStateComputer)

	/** 
	 * The parameters of this constructor define the list of the processors and
	 * the order in which they'll be applied.
	 * Yes, that does not make sense, but we don't have Guice Multibindings here.
	 */
	@Inject
	new(
		WildcardAspectResolver r,
		LanguageProcessor l,
		ExactTypeInferrer e,
		TypingInferrer t
	) {
		processors += r
		processors += e
		processors += l
		processors += t
	}

	/**
	 * Resets the current state of the {@link EPackageProvider} to discard
	 * obsolete {@link EPackage}/{@link GenModel} cache. Then, call each
	 * {@link MelangeProcessor} in the right order to give them a chance to
	 * process the AST. Finally, simply delegate to the super installDerivedState.
	 */
	override installDerivedState(
		DerivedStateAwareResource resource,
		boolean preLinkingPhase
	) {
		log.debug('''installDerivedState() from [Thread «Thread.currentThread.id»]''')
		val task = Stopwatches.forTask("installing derived state")
		task.start

		// In a test environment, automatic XMLNamespacePackage
		// initialization may fail for no apparent reason
		val testsBug = XMLNamespacePackage::eINSTANCE
		// Just to avoid the unused warning
		testsBug.hashCode

		// Activate stop watches before anything happens
		Stopwatches.enabled = true

		// Reset EPackage provider registry
		provider.resetFor(resource)

		// Pre-inferring processors
		val root = resource.contents.head as ModelTypingSpace

		if (root !== null) {
			try {
				processors.forEach[p |
					val pTask = Stopwatches.forTask(p.class.simpleName)
					pTask.start
					p.preProcess(root, preLinkingPhase)
					pTask.stop
				]

				// Setting context for non-inferrer helper classes
				builder.setContext(resource.resourceSet)
				helper.setContext(resource.resourceSet)

				task.stop
				// Avoid computing all the derived state when unnecessary,
				// ie. if we don't have Xbase code in transformations that
				// relies on the code generated by Melange, we don't need
				// to call the codegen phase
				if (root.containsTransformations)
					super.installDerivedState(resource, preLinkingPhase)
				else
					super.installDerivedState(resource, true)
			} catch (Exception e) {
				log.error("Fatal exception", e)
			}
		}
	}

	/**
	 * Gives an opportunity to the {@link MelangeProcessor}s to discard
	 * their modification of the AST of {@code resource}, and prints the
	 * stopwatches collected along the way.
	 */
	override discardDerivedState(DerivedStateAwareResource resource) {
		// Post-inferring processors
		val root = resource.contents.head as ModelTypingSpace

		if (root !== null)
			processors.forEach[postProcess(root)]

		super.discardDerivedState(resource)

		// Print stop watches metrics
		log.debug(Stopwatches.getPrintableStopwatchData)
		Stopwatches.resetAll
	}

	def boolean containsTransformations(ModelTypingSpace root) {
		return !root.elements.filter(Transformation).empty
	}

	/**
	 * Should be invoked right before code generation to complete
	 * the derived state model
	 */
	def void inferFullDerivedState(DerivedStateAwareResource resource) {
		super.installDerivedState(resource, false)
	}
}
