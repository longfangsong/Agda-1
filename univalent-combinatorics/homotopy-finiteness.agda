{-# OPTIONS --without-K --exact-split --allow-unsolved-metas #-}

module univalent-combinatorics.homotopy-finiteness where

open import book.18-set-quotients public

{-------------------------------------------------------------------------------

  Univalent combinatorics

-------------------------------------------------------------------------------}

-- Section 1. Homotopy finiteness

-- Definition 1.3

-- We introduce locally finite types

is-locally-finite-Prop :
  {l : Level} → UU l → UU-Prop l
is-locally-finite-Prop A =
  Π-Prop A (λ x → Π-Prop A (λ y → is-finite-Prop (Id x y)))

is-locally-finite : {l : Level} → UU l → UU l
is-locally-finite A = type-Prop (is-locally-finite-Prop A)

is-prop-is-locally-finite :
  {l : Level} (A : UU l) → is-prop (is-locally-finite A)
is-prop-is-locally-finite A = is-prop-type-Prop (is-locally-finite-Prop A)

-- We introduce strong homotopy finite types

is-strong-homotopy-finite-Prop : {l : Level} (k : ℕ) → UU l → UU-Prop l
is-strong-homotopy-finite-Prop zero-ℕ X = is-finite-Prop X
is-strong-homotopy-finite-Prop (succ-ℕ k) X =
  prod-Prop
    ( is-finite-Prop (type-trunc-Set X))
    ( Π-Prop X
      ( λ x → Π-Prop X (λ y → is-strong-homotopy-finite-Prop k (Id x y))))

is-homotopy-finite-Prop : {l : Level} (k : ℕ) → UU l → UU-Prop l
is-homotopy-finite-Prop zero-ℕ X = is-finite-Prop (type-trunc-Set X)
is-homotopy-finite-Prop (succ-ℕ k) X =
  prod-Prop ( is-finite-Prop (type-trunc-Set X))
            ( Π-Prop X
              ( λ x → Π-Prop X (λ y → is-homotopy-finite-Prop k (Id x y))))

-- We introduce homotopy finite types

is-homotopy-finite : {l : Level} (k : ℕ) → UU l → UU l
is-homotopy-finite k X = type-Prop (is-homotopy-finite-Prop k X)

is-prop-is-homotopy-finite :
  {l : Level} (k : ℕ) (X : UU l) → is-prop (is-homotopy-finite k X)
is-prop-is-homotopy-finite k X =
  is-prop-type-Prop (is-homotopy-finite-Prop k X)

-- Basic properties of locally finite types

-- locally finite types are closed under equivalences

is-locally-finite-equiv :
  {l1 l2 : Level} {A : UU l1} {B : UU l2} (e : A ≃ B) →
  is-locally-finite B → is-locally-finite A
is-locally-finite-equiv e f x y =
  is-finite-equiv' (equiv-ap e x y) (f (map-equiv e x) (map-equiv e y))

is-locally-finite-equiv' :
  {l1 l2 : Level} {A : UU l1} {B : UU l2} (e : A ≃ B) →
  is-locally-finite A → is-locally-finite B
is-locally-finite-equiv' e = is-locally-finite-equiv (inv-equiv e)

-- types with decidable equality are locally finite

is-locally-finite-has-decidable-equality :
  {l1 : Level} {A : UU l1} → has-decidable-equality A → is-locally-finite A
is-locally-finite-has-decidable-equality d x y = is-finite-eq d

-- any proposition is locally finite

is-locally-finite-is-prop :
  {l1 : Level} {A : UU l1} → is-prop A → is-locally-finite A
is-locally-finite-is-prop H x y = is-finite-is-contr (H x y)

-- any contractible type is locally finite

is-locally-finite-is-contr :
  {l1 : Level} {A : UU l1} → is-contr A → is-locally-finite A
is-locally-finite-is-contr H =
  is-locally-finite-is-prop (is-prop-is-contr H)

is-locally-finite-unit : is-locally-finite unit
is-locally-finite-unit = is-locally-finite-is-contr is-contr-unit

-- any empty type is locally finite

is-locally-finite-is-empty :
  {l1 : Level} {A : UU l1} → is-empty A → is-locally-finite A
is-locally-finite-is-empty H = is-locally-finite-is-prop (λ x → ex-falso (H x))

is-locally-finite-empty : is-locally-finite empty
is-locally-finite-empty = is-locally-finite-is-empty id

-- Basic properties of homotopy finiteness

is-homotopy-finite-equiv :
  {l1 l2 : Level} (k : ℕ) {A : UU l1} {B : UU l2} (e : A ≃ B) →
  is-homotopy-finite k B → is-homotopy-finite k A
is-homotopy-finite-equiv zero-ℕ e H =
  is-finite-equiv' (equiv-trunc-Set e) H
is-homotopy-finite-equiv (succ-ℕ k) e H =
  pair
    ( is-homotopy-finite-equiv zero-ℕ e (pr1 H))
    ( λ a b →
      is-homotopy-finite-equiv k
        ( equiv-ap e a b)
        ( pr2 H (map-equiv e a) (map-equiv e b)))

is-homotopy-finite-equiv' :
  {l1 l2 : Level} (k : ℕ) {A : UU l1} {B : UU l2} (e : A ≃ B) →
  is-homotopy-finite k A → is-homotopy-finite k B
is-homotopy-finite-equiv' k e = is-homotopy-finite-equiv k (inv-equiv e)

is-homotopy-finite-empty : (k : ℕ) → is-homotopy-finite k empty
is-homotopy-finite-empty zero-ℕ =
  is-finite-equiv equiv-unit-trunc-empty-Set is-finite-empty
is-homotopy-finite-empty (succ-ℕ k) =
  pair (is-homotopy-finite-empty zero-ℕ) ind-empty

is-homotopy-finite-coprod :
  {l1 l2 : Level} (k : ℕ) {A : UU l1} {B : UU l2} →
  is-homotopy-finite k A → is-homotopy-finite k B →
  is-homotopy-finite k (coprod A B)
is-homotopy-finite-coprod zero-ℕ H K =
  is-finite-equiv'
    ( equiv-distributive-trunc-coprod-Set _ _)
    ( is-finite-coprod H K)
is-homotopy-finite-coprod (succ-ℕ k) H K =
  pair
    ( is-homotopy-finite-coprod zero-ℕ (pr1 H) (pr1 K))
    ( λ { (inl x) (inl y) →
          is-homotopy-finite-equiv k
            ( compute-eq-coprod-inl-inl x y)
            ( pr2 H x y) ;
          (inl x) (inr y) →
          is-homotopy-finite-equiv k
            ( compute-eq-coprod-inl-inr x y)
            ( is-homotopy-finite-empty k) ;
          (inr x) (inl y) →
          is-homotopy-finite-equiv k
            ( compute-eq-coprod-inr-inl x y)
            ( is-homotopy-finite-empty k) ;
          (inr x) (inr y) →
          is-homotopy-finite-equiv k
            ( compute-eq-coprod-inr-inr x y)
            ( pr2 K x y)})

-- Proposition 1.5

-- Dependent product of locally finite types

is-locally-finite-prod :
  {l1 l2 : Level} {A : UU l1} {B : UU l2} →
  is-locally-finite A → is-locally-finite B → is-locally-finite (A × B)
is-locally-finite-prod f g x y =
  is-finite-equiv
    ( equiv-eq-pair x y)
    ( is-finite-prod (f (pr1 x) (pr1 y)) (g (pr2 x) (pr2 y)))

is-locally-finite-Π-Fin :
  {l1 : Level} {k : ℕ} {B : Fin k → UU l1} →
  ((x : Fin k) → is-locally-finite (B x)) →
  is-locally-finite ((x : Fin k) → B x)
is-locally-finite-Π-Fin {l1} {zero-ℕ} {B} f =
  is-locally-finite-is-contr (dependent-universal-property-empty' B)
is-locally-finite-Π-Fin {l1} {succ-ℕ k} {B} f =
  is-locally-finite-equiv
    ( equiv-dependent-universal-property-coprod B)
    ( is-locally-finite-prod
      ( is-locally-finite-Π-Fin (λ x → f (inl x)))
      ( is-locally-finite-equiv
        ( equiv-ev-star (B ∘ inr))
        ( f (inr star))))

is-locally-finite-Π-count :
  {l1 l2 : Level} {A : UU l1} {B : A → UU l2} → count A →
  ((x : A) → is-locally-finite (B x)) → is-locally-finite ((x : A) → B x)
is-locally-finite-Π-count {l1} {l2} {A} {B} (pair k e) g =
  is-locally-finite-equiv
    ( equiv-precomp-Π e B )
    ( is-locally-finite-Π-Fin (λ x → g (map-equiv e x)))

is-locally-finite-Π :
  {l1 l2 : Level} {A : UU l1} {B : A → UU l2} → is-finite A →
  ((x : A) → is-locally-finite (B x)) → is-locally-finite ((x : A) → B x)
is-locally-finite-Π {l1} {l2} {A} {B} f g =
  apply-universal-property-trunc-Prop f
    ( is-locally-finite-Prop ((x : A) → B x))
    ( λ e → is-locally-finite-Π-count e g)

-- Finite products of homotopy finite types

is-homotopy-finite-Π-is-finite :
  {l1 l2 : Level} (k : ℕ) {A : UU l1} {B : A → UU l2} →
  is-finite A → ((a : A) → is-homotopy-finite k (B a)) →
  is-homotopy-finite k ((a : A) → B a)
is-homotopy-finite-Π-is-finite zero-ℕ {A} {B} H K =
  is-finite-equiv'
    ( equiv-distributive-trunc-Π-is-finite-Set B H)
    ( is-finite-Π H K)
is-homotopy-finite-Π-is-finite (succ-ℕ k) H K =
  pair
    ( is-homotopy-finite-Π-is-finite zero-ℕ H (λ a → pr1 (K a)))
    ( λ f g →
      is-homotopy-finite-equiv k
        ( equiv-funext)
        ( is-homotopy-finite-Π-is-finite k H (λ a → pr2 (K a) (f a) (g a))))

-- Proposition 1.6

is-locally-finite-Σ :
  {l1 l2 : Level} {A : UU l1} {B : A → UU l2} →
  is-locally-finite A → ((x : A) → is-locally-finite (B x)) →
  is-locally-finite (Σ A B)
is-locally-finite-Σ {B = B} H K (pair x y) (pair x' y') =
  is-finite-equiv'
    ( equiv-pair-eq-Σ (pair x y) (pair x' y'))
    ( is-finite-Σ (H x x') (λ p → K x' (tr B p y) y'))

-- Proposition 1.7

is-homotopy-finite-Σ-is-set-connected :
  {l1 l2 : Level} {A : UU l1} {B : A → UU l2} →
  is-set-connected A → is-homotopy-finite one-ℕ A →
  ((x : A) → is-homotopy-finite zero-ℕ (B x)) →
  is-homotopy-finite zero-ℕ (Σ A B)
is-homotopy-finite-Σ-is-set-connected {A = A} {B} C H K =
  apply-universal-property-trunc-Prop
    ( is-inhabited-is-set-connected C)
    ( is-homotopy-finite-Prop zero-ℕ (Σ A B))
    ( α)
    
  where
  α : A → is-homotopy-finite zero-ℕ (Σ A B)
  α a =
    is-finite-codomain-has-decidable-equality
      ( K a)
      ( is-surjective-map-trunc-Set
        ( fiber-inclusion B a)
        ( is-surjective-fiber-inclusion C a))
      ( apply-dependent-universal-property-trunc-Set
        ( λ x →
          set-Prop
            ( Π-Prop
              ( type-trunc-Set (Σ A B))
              ( λ y → is-decidable-Prop (Id-Prop (trunc-Set (Σ A B)) x y))))
        ( β))
        
    where
    β : (x : Σ A B) (v : type-trunc-Set (Σ A B)) →
        is-decidable (Id (unit-trunc-Set x) v)
    β (pair x y) =
      apply-dependent-universal-property-trunc-Set
        ( λ u →
          set-Prop
            ( is-decidable-Prop
              ( Id-Prop (trunc-Set (Σ A B)) (unit-trunc-Set (pair x y)) u)))
        ( γ)
        
      where
      γ : (v : Σ A B) →
          is-decidable (Id (unit-trunc-Set (pair x y)) (unit-trunc-Set v))
      γ (pair x' y') =
        is-decidable-equiv
          ( is-effective-unit-trunc-Set
            ( Σ A B)
            ( pair x y)
            ( pair x' y'))
          ( apply-universal-property-trunc-Prop
            ( mere-eq-is-set-connected C a x)
            ( is-decidable-Prop
              ( mere-eq-Prop (pair x y) (pair x' y')))
              ( δ))
              
        where
        δ : Id a x → is-decidable (mere-eq (pair x y) (pair x' y'))
        δ refl =
          apply-universal-property-trunc-Prop
            ( mere-eq-is-set-connected C a x')
            ( is-decidable-Prop
              ( mere-eq-Prop (pair a y) (pair x' y')))
            ( ε)
            
          where
          ε : Id a x' → is-decidable (mere-eq (pair x y) (pair x' y'))
          ε refl =
            is-decidable-equiv e
              ( is-decidable-type-trunc-Prop-is-finite
                ( is-finite-Σ
                  ( pr2 H a a)
                  {! is-finite-is-decidable-subtype!}))
            
            where
            ℙ : is-contr
                ( Σ ( type-hom-Set (trunc-Set (Id a a)) (UU-Prop-Set _))
                    ( λ h →
                      ( λ a₁ → h (unit-trunc-Set a₁)) ~
                      ( λ ω₁ → trunc-Prop (Id (tr B ω₁ y) y'))))
            ℙ = universal-property-trunc-Set
                ( Id a a)
                ( UU-Prop-Set _)
                ( λ ω → trunc-Prop (Id (tr B ω y) y'))
            P : type-trunc-Set (Id a a) → UU-Prop _
            P = pr1 (center ℙ)
            compute-P :
              ( ω₁ : Id a a) →
              type-trunc-Prop (Id (tr B ω₁ y) y') ≃
              type-Prop (P (unit-trunc-Set ω₁))
            compute-P ω = inv-equiv (equiv-eq (ap pr1 (pr2 (center ℙ) ω)))
            d : (t : type-trunc-Set (Id a a)) → is-decidable (type-Prop (P t))
            d = apply-dependent-universal-property-trunc-Set
                ( λ t → set-Prop (is-decidable-Prop (P t)))
                ( λ ω →
                  is-decidable-equiv'
                    ( compute-P ω)
                    ( is-decidable-equiv'
                      ( is-effective-unit-trunc-Set (B a) (tr B ω y) y')
                      ( has-decidable-equality-is-finite
                        ( K a)
                        ( unit-trunc-Set (tr B ω y))
                        ( unit-trunc-Set y'))))
            f : type-hom-Prop
                ( trunc-Prop (Σ (type-trunc-Set (Id a a)) (type-Prop ∘ P)))
                ( mere-eq-Prop {A = Σ A B} (pair a y) (pair a y'))
            f = {!!}
            e : mere-eq {A = Σ A B} (pair a y) (pair a y') ≃
                type-trunc-Prop (Σ (type-trunc-Set (Id a a)) (type-Prop ∘ P))
            e = equiv-iff
                  ( mere-eq-Prop (pair a y) (pair a y'))
                  ( trunc-Prop (Σ (type-trunc-Set (Id a a)) (type-Prop ∘ P)))
                  ( λ t →
                    apply-universal-property-trunc-Prop t
                      ( trunc-Prop _)
                      ( ( λ { (pair ω r) →
                            unit-trunc-Prop
                              ( pair
                                ( unit-trunc-Set ω)
                                ( map-inv-equiv
                                  ( equiv-eq
                                    ( ap pr1
                                      ( triangle-universal-property-trunc-Set
                                        ( UU-Prop-Set _)
                                        ( λ ω' →
                                          trunc-Prop
                                            ( Id (tr B ω' y) y')) ω)))
                                            ( unit-trunc-Prop r)))}) ∘
                        ( pair-eq-Σ)))
                  ( f)
