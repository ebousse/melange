/**
 */
package fr.inria.diverse.melange.metamodel.melange.impl;

import fr.inria.diverse.melange.metamodel.melange.Language;
import fr.inria.diverse.melange.metamodel.melange.MelangePackage;
import fr.inria.diverse.melange.metamodel.melange.Slice;

import java.util.Collection;

import org.eclipse.emf.common.notify.Notification;

import org.eclipse.emf.common.util.EList;

import org.eclipse.emf.ecore.EClass;
import org.eclipse.emf.ecore.InternalEObject;

import org.eclipse.emf.ecore.impl.ENotificationImpl;

import org.eclipse.emf.ecore.util.EDataTypeUniqueEList;

/**
 * <!-- begin-user-doc -->
 * An implementation of the model object '<em><b>Slice</b></em>'.
 * <!-- end-user-doc -->
 * <p>
 * The following features are implemented:
 * </p>
 * <ul>
 *   <li>{@link fr.inria.diverse.melange.metamodel.melange.impl.SliceImpl#getSlicedLanguage <em>Sliced Language</em>}</li>
 *   <li>{@link fr.inria.diverse.melange.metamodel.melange.impl.SliceImpl#getRoots <em>Roots</em>}</li>
 * </ul>
 *
 * @generated
 */
public class SliceImpl extends OperatorImpl implements Slice {
	/**
	 * The cached value of the '{@link #getSlicedLanguage() <em>Sliced Language</em>}' reference.
	 * <!-- begin-user-doc -->
	 * <!-- end-user-doc -->
	 * @see #getSlicedLanguage()
	 * @generated
	 * @ordered
	 */
	protected Language slicedLanguage;

	/**
	 * The cached value of the '{@link #getRoots() <em>Roots</em>}' attribute list.
	 * <!-- begin-user-doc -->
	 * <!-- end-user-doc -->
	 * @see #getRoots()
	 * @generated
	 * @ordered
	 */
	protected EList<String> roots;

	/**
	 * <!-- begin-user-doc -->
	 * <!-- end-user-doc -->
	 * @generated
	 */
	protected SliceImpl() {
		super();
	}

	/**
	 * <!-- begin-user-doc -->
	 * <!-- end-user-doc -->
	 * @generated
	 */
	@Override
	protected EClass eStaticClass() {
		return MelangePackage.Literals.SLICE;
	}

	/**
	 * <!-- begin-user-doc -->
	 * <!-- end-user-doc -->
	 * @generated
	 */
	public Language getSlicedLanguage() {
		if (slicedLanguage != null && slicedLanguage.eIsProxy()) {
			InternalEObject oldSlicedLanguage = (InternalEObject)slicedLanguage;
			slicedLanguage = (Language)eResolveProxy(oldSlicedLanguage);
			if (slicedLanguage != oldSlicedLanguage) {
				if (eNotificationRequired())
					eNotify(new ENotificationImpl(this, Notification.RESOLVE, MelangePackage.SLICE__SLICED_LANGUAGE, oldSlicedLanguage, slicedLanguage));
			}
		}
		return slicedLanguage;
	}

	/**
	 * <!-- begin-user-doc -->
	 * <!-- end-user-doc -->
	 * @generated
	 */
	public Language basicGetSlicedLanguage() {
		return slicedLanguage;
	}

	/**
	 * <!-- begin-user-doc -->
	 * <!-- end-user-doc -->
	 * @generated
	 */
	public void setSlicedLanguage(Language newSlicedLanguage) {
		Language oldSlicedLanguage = slicedLanguage;
		slicedLanguage = newSlicedLanguage;
		if (eNotificationRequired())
			eNotify(new ENotificationImpl(this, Notification.SET, MelangePackage.SLICE__SLICED_LANGUAGE, oldSlicedLanguage, slicedLanguage));
	}

	/**
	 * <!-- begin-user-doc -->
	 * <!-- end-user-doc -->
	 * @generated
	 */
	public EList<String> getRoots() {
		if (roots == null) {
			roots = new EDataTypeUniqueEList<String>(String.class, this, MelangePackage.SLICE__ROOTS);
		}
		return roots;
	}

	/**
	 * <!-- begin-user-doc -->
	 * <!-- end-user-doc -->
	 * @generated
	 */
	@Override
	public Object eGet(int featureID, boolean resolve, boolean coreType) {
		switch (featureID) {
			case MelangePackage.SLICE__SLICED_LANGUAGE:
				if (resolve) return getSlicedLanguage();
				return basicGetSlicedLanguage();
			case MelangePackage.SLICE__ROOTS:
				return getRoots();
		}
		return super.eGet(featureID, resolve, coreType);
	}

	/**
	 * <!-- begin-user-doc -->
	 * <!-- end-user-doc -->
	 * @generated
	 */
	@SuppressWarnings("unchecked")
	@Override
	public void eSet(int featureID, Object newValue) {
		switch (featureID) {
			case MelangePackage.SLICE__SLICED_LANGUAGE:
				setSlicedLanguage((Language)newValue);
				return;
			case MelangePackage.SLICE__ROOTS:
				getRoots().clear();
				getRoots().addAll((Collection<? extends String>)newValue);
				return;
		}
		super.eSet(featureID, newValue);
	}

	/**
	 * <!-- begin-user-doc -->
	 * <!-- end-user-doc -->
	 * @generated
	 */
	@Override
	public void eUnset(int featureID) {
		switch (featureID) {
			case MelangePackage.SLICE__SLICED_LANGUAGE:
				setSlicedLanguage((Language)null);
				return;
			case MelangePackage.SLICE__ROOTS:
				getRoots().clear();
				return;
		}
		super.eUnset(featureID);
	}

	/**
	 * <!-- begin-user-doc -->
	 * <!-- end-user-doc -->
	 * @generated
	 */
	@Override
	public boolean eIsSet(int featureID) {
		switch (featureID) {
			case MelangePackage.SLICE__SLICED_LANGUAGE:
				return slicedLanguage != null;
			case MelangePackage.SLICE__ROOTS:
				return roots != null && !roots.isEmpty();
		}
		return super.eIsSet(featureID);
	}

	/**
	 * <!-- begin-user-doc -->
	 * <!-- end-user-doc -->
	 * @generated
	 */
	@Override
	public String toString() {
		if (eIsProxy()) return super.toString();

		StringBuffer result = new StringBuffer(super.toString());
		result.append(" (roots: ");
		result.append(roots);
		result.append(')');
		return result.toString();
	}

} //SliceImpl