{-# OPTIONS --without-K --exact-split --allow-unsolved-metas #-}

module extra.interchange where

import book
open book public

--------------------------------------------------------------------------------

{- Binary equivalences and binary embeddings -}

is-binary-equiv :
  {l1 l2 l3 : Level} {A : UU l1} {B : UU l2} {C : UU l3} →
  (A → B → C) → UU (l1 ⊔ l2 ⊔ l3)
is-binary-equiv {A = A} {B = B} f =
  ((b : B) → is-equiv (λ x → f x b)) × ((a : A) → is-equiv (λ y → f a y))

is-equiv-fix-left :
  {l1 l2 l3 : Level} {A : UU l1} {B : UU l2} {C : UU l3} (f : A → B → C) →
  is-binary-equiv f → {a : A} → is-equiv (λ y → f a y)
is-equiv-fix-left f H {a} = pr2 H a

is-emb-fix-left-is-binary-equiv :
  {l1 l2 l3 : Level} {A : UU l1} {B : UU l2} {C : UU l3} (f : A → B → C) →
  is-binary-equiv f → {a : A} → is-emb (λ y → f a y)
is-emb-fix-left-is-binary-equiv f H {a} =
  is-emb-is-equiv (λ y → f a y) (is-equiv-fix-left f H)

is-equiv-fix-right :
  {l1 l2 l3 : Level} {A : UU l1} {B : UU l2} {C : UU l3} (f : A → B → C) →
  is-binary-equiv f → {b : B} → is-equiv (λ x → f x b)
is-equiv-fix-right f H {b} = pr1 H b

is-emb-fix-right-is-binary-equiv :
  {l1 l2 l3 : Level} {A : UU l1} {B : UU l2} {C : UU l3} (f : A → B → C) →
  is-binary-equiv f → {b : B} → is-emb (λ x → f x b)
is-emb-fix-right-is-binary-equiv f H {b} =
  is-emb-is-equiv (λ x → f x b) (is-equiv-fix-right f H)

is-binary-equiv-concat :
  {l : Level} {A : UU l} {x y z : A} →
  is-binary-equiv (λ (p : Id x y) (q : Id y z) → p ∙ q)
is-binary-equiv-concat {l} {A} {x} {y} {z} =
  pair (λ q → is-equiv-concat' x q) (λ p → is-equiv-concat p z)

is-binary-emb :
  {l1 l2 l3 : Level} {A : UU l1} {B : UU l2} {C : UU l3} →
  (A → B → C) → UU (l1 ⊔ l2 ⊔ l3)
is-binary-emb {A = A} {B = B} f =
  {x x' : A} {y y' : B} →
    is-binary-equiv (λ (p : Id x x') (q : Id y y') → ap-binary f p q)

is-binary-emb-is-binary-equiv :
  {l1 l2 l3 : Level} {A : UU l1} {B : UU l2} {C : UU l3} (f : A → B → C) →
  is-binary-equiv f → is-binary-emb f
is-binary-emb-is-binary-equiv f H {x} {x'} {y} {y'} =
  pair
    ( λ q →
      is-equiv-comp
        ( λ p → ap-binary f p q)
        ( concat' (f x y) (ap (λ z → f x' z) q))
        ( λ p → ap (λ z → f z y) p)
        ( λ p → triangle-ap-binary f p q)
        ( is-emb-fix-right-is-binary-equiv f H x x')
        ( is-equiv-concat' (f x y) (ap (λ z → f x' z) q)))
    ( λ p →
      is-equiv-comp
        ( λ q → ap-binary f p q)
        ( concat (ap (λ z → f z y) p) (f x' y'))
        ( λ q → ap (f x') q)
        ( λ q → triangle-ap-binary f p q)
        ( is-emb-fix-left-is-binary-equiv f H y y')
        ( is-equiv-concat (ap (λ z → f z y) p) (f x' y')))

--------------------------------------------------------------------------------

{- Identity types of identity types -}

vertical-concat :
  {l : Level} {A : UU l} {x y : A} {p q r : Id x y} → Id p q → Id q r → Id p r
vertical-concat α β = α ∙ β

is-binary-equiv-vertical-concat :
  {l : Level} {A : UU l} {x y : A} {p q r : Id x y} →
  is-binary-equiv (vertical-concat {l} {A} {x} {y} {p} {q} {r})
is-binary-equiv-vertical-concat = is-binary-equiv-concat

ap-vertical-concat :
  {l : Level} {A : UU l} {x y : A} {p q r : Id x y} {α α' : Id p q}
  (s : Id α α') {β β' : Id q r} (t : Id β β') →
  Id (vertical-concat α β) (vertical-concat α' β')
ap-vertical-concat s t = ap-binary vertical-concat s t

horizontal-concat :
  {l : Level} {A : UU l} {x y z : A} {p q : Id x y} {u v : Id y z} →
  Id p q → Id u v → Id (p ∙ u) (q ∙ v)
horizontal-concat α β = ap-binary (λ s t → s ∙ t) α β

is-binary-equiv-horizontal-concat :
  {l : Level} {A : UU l} {x y z : A} {p q : Id x y} {u v : Id y z} →
  is-binary-equiv (horizontal-concat {l} {A} {x} {y} {z} {p} {q} {u} {v})
is-binary-equiv-horizontal-concat =
  is-binary-emb-is-binary-equiv (λ s t → s ∙ t) is-binary-equiv-concat

left-unit-law-horizontal-concat :
  {l : Level} {A : UU l} {x y z : A} {p : Id x y} {u v : Id y z} (γ : Id u v) →
  Id (horizontal-concat (refl {x = p}) γ) (ap (concat p z) γ)
left-unit-law-horizontal-concat refl = refl

right-unit-law-horizontal-concat :
  {l : Level} {A : UU l} {x y z : A} {p q : Id x y} (α : Id p q) {u : Id y z} →
  Id (horizontal-concat α (refl {x = u})) (ap (concat' x u) α)
right-unit-law-horizontal-concat refl = refl

ap-horizontal-concat :
  {l : Level} {A : UU l} {x y z : A} {p q : Id x y} {u v : Id y z} →
  {α α' : Id p q} (s : Id α α') {β β' : Id u v} (t : Id β β') →
  Id (horizontal-concat α β) (horizontal-concat α' β')
ap-horizontal-concat s t = ap-binary horizontal-concat s t

interchange-Id² :
  {l : Level} {A : UU l} {x y z : A} {p q r : Id x y} {u v w : Id y z}
  (α : Id p q) (β : Id q r) (γ : Id u v) (δ : Id v w) →
  Id ( horizontal-concat (vertical-concat α β) (vertical-concat γ δ))
     ( vertical-concat (horizontal-concat α γ) (horizontal-concat β δ))
interchange-Id² refl refl refl refl = refl

unit-law-α-interchange-Id² :
  {l : Level} {A : UU l} {x y z : A} {p q : Id x y} (α : Id p q) (u : Id y z) →
  Id ( ( interchange-Id² α refl (refl {x = u}) refl) ∙
       ( right-unit ∙ right-unit-law-horizontal-concat α))
     ( ( right-unit-law-horizontal-concat (α ∙ refl)) ∙
       ( ap (ap (concat' x u)) right-unit))
unit-law-α-interchange-Id² refl u = refl

unit-law-β-interchange-Id² :
  {l : Level} {A : UU l} {x y z : A} {p q : Id x y} (β : Id p q) (u : Id y z) →
  Id ( interchange-Id² refl β (refl {x = u}) refl) refl
unit-law-β-interchange-Id² refl u = refl

unit-law-γ-interchange-Id² :
  {l : Level} {A : UU l} {x y z : A} (p : Id x y) {u v : Id y z} (γ : Id u v) →
  Id ( ( interchange-Id² (refl {x = p}) refl γ refl) ∙
       ( right-unit ∙ left-unit-law-horizontal-concat γ))
     ( ( left-unit-law-horizontal-concat (γ ∙ refl)) ∙
       ( ap (ap (concat p z)) right-unit))
unit-law-γ-interchange-Id² p refl = refl

unit-law-δ-interchange-Id² :
  {l : Level} {A : UU l} {x y z : A} (p : Id x y) {u v : Id y z} (δ : Id u v) →
  Id ( interchange-Id² (refl {x = p}) refl refl δ) refl
unit-law-δ-interchange-Id² p refl = refl

--------------------------------------------------------------------------------

{- The double loop space -}

vertical-concat-Ω² :
  {l : Level} {A : UU l} {a : A} → type-Ω² a → type-Ω² a → type-Ω² a
vertical-concat-Ω² α β = vertical-concat α β

left-unit-law-vertical-concat-Ω² :
  {l : Level} {A : UU l} {a : A} {α : type-Ω² a} →
  Id (vertical-concat-Ω² refl-Ω² α) α
left-unit-law-vertical-concat-Ω² = left-unit

right-unit-law-vertical-concat-Ω² :
  {l : Level} {A : UU l} {a : A} {α : type-Ω² a} →
  Id (vertical-concat-Ω² α refl-Ω²) α
right-unit-law-vertical-concat-Ω² = right-unit

horizontal-concat-Ω² :
  {l : Level} {A : UU l} {a : A} → type-Ω² a → type-Ω² a → type-Ω² a
horizontal-concat-Ω² α β = horizontal-concat α β

left-unit-law-horizontal-concat-Ω² :
  {l : Level} {A : UU l} {a : A} {α : type-Ω² a} →
  Id (horizontal-concat-Ω² refl-Ω² α) α
left-unit-law-horizontal-concat-Ω² {α = α} =
  ( left-unit-law-horizontal-concat α) ∙ (ap-id α)

right-unit-law-horizontal-concat-Ω² :
  {l : Level} {A : UU l} {a : A} {α : type-Ω² a} →
  Id (horizontal-concat-Ω² α refl-Ω²) α
right-unit-law-horizontal-concat-Ω² {α = α} =
  ( right-unit-law-horizontal-concat α) ∙
  ( ( inv right-unit) ∙
    ( ( inv (htpy-nat {g = id} (λ t → right-unit) α)) ∙
      ( ap (concat right-unit refl) (ap-id α))))

interchange-Ω² :
  {l : Level} {A : UU l} {a : A} (α β γ δ : type-Ω² a) →
  Id ( horizontal-concat-Ω² (vertical-concat-Ω² α β) (vertical-concat-Ω² γ δ))
     ( vertical-concat-Ω² (horizontal-concat-Ω² α γ) (horizontal-concat-Ω² β δ))
interchange-Ω² α β γ δ = interchange-Id² α β γ δ

unit-law-α-interchange-Ω² :
  {l : Level} {A : UU l} {a : A} (α : type-Ω² a) →
  Id ( ( interchange-Ω² α refl-Ω² refl-Ω² refl-Ω²) ∙
       ( right-unit ∙ right-unit-law-horizontal-concat-Ω²))
     ( right-unit-law-horizontal-concat-Ω² ∙ right-unit)
unit-law-α-interchange-Ω² α = {!unit-law-α-interchange-Id² α refl!}

eckmann-hilton-Ω² :
  {l : Level} {A : UU l} {a : A} (α β : type-Ω² a) →
  Id (α ∙ β) (β ∙ α)
eckmann-hilton-Ω² α β =
  ( ap-vertical-concat
    ( inv (right-unit-law-horizontal-concat-Ω² {α = α}))
    ( inv left-unit-law-horizontal-concat-Ω²)) ∙
  ( ( inv (interchange-Ω² α refl-Ω² refl-Ω² β)) ∙
    ( ( ap-horizontal-concat right-unit (inv right-unit)) ∙
      ( ( interchange-Ω² refl-Ω² α β refl-Ω²) ∙
        ( ap-vertical-concat
          ( left-unit-law-horizontal-concat-Ω² {α = β})
          ( right-unit-law-horizontal-concat-Ω² {α = α})))))

--------------------------------------------------------------------------------

-- Identity types of identity types of identity types

x-concat-Id³ :
  {l : Level} {A : UU l} {x y : A} {p q : Id x y} {α β γ : Id p q} →
  Id α β → Id β γ → Id α γ
x-concat-Id³ σ τ = σ ∙ τ

y-concat-Id³ :
  {l : Level} {A : UU l} {x y : A} {p q r : Id x y} {α β : Id p q}
  {γ δ : Id q r} → Id α β → Id γ δ → Id (α ∙ γ) (β ∙ δ)
y-concat-Id³ σ τ = horizontal-concat σ τ

z-concat-Id³ :
  {l : Level} {A : UU l} {x y z : A} {p q : Id x y} {u v : Id y z}
  {α β : Id p q} {γ δ : Id u v} →
  Id α β → Id γ δ → Id (horizontal-concat α γ) (horizontal-concat β δ)
z-concat-Id³ σ τ = ap-binary (λ s t → horizontal-concat s t) σ τ

left-unit-law-x-concat-Id³ :
  {l : Level} {A : UU l} {x y : A} {p q : Id x y} {α β : Id p q} {τ : Id α β} →
  Id (x-concat-Id³ refl τ) τ
left-unit-law-x-concat-Id³ = left-unit

right-unit-law-x-concat-Id³ :
  {l : Level} {A : UU l} {x y : A} {p q : Id x y} {α β : Id p q} {τ : Id α β} →
  Id (x-concat-Id³ τ refl) τ
right-unit-law-x-concat-Id³ = right-unit

left-unit-law-y-concat-Id³ :
  {l : Level} {A : UU l} {x y : A} {p q r : Id x y} {α : Id p q} {γ δ : Id q r}
  {τ : Id γ δ} → Id (y-concat-Id³ (refl {x = α}) τ) (ap (concat α r) τ)
left-unit-law-y-concat-Id³ {τ = τ} = left-unit-law-horizontal-concat τ

right-unit-law-y-concat-Id³ :
  {l : Level} {A : UU l} {x y : A} {p q r : Id x y} {α β : Id p q} {γ : Id q r}
  {σ : Id α β} → Id (y-concat-Id³ σ (refl {x = γ})) (ap (concat' p γ) σ)
right-unit-law-y-concat-Id³ {σ = σ} = right-unit-law-horizontal-concat σ

left-unit-law-z-concat-Id³ :
  {l : Level} {A : UU l} {x y z : A} {p q : Id x y} {u v : Id y z}
  {α : Id p q} {γ δ : Id u v} (τ : Id γ δ) →
  Id (z-concat-Id³ (refl {x = α}) τ) (ap (horizontal-concat α) τ)
left-unit-law-z-concat-Id³ refl = refl

right-unit-law-z-concat-Id³ :
  {l : Level} {A : UU l} {x y z : A} {p q : Id x y} {u v : Id y z}
  {α β : Id p q} {γ : Id u v} (σ : Id α β) →
  Id (z-concat-Id³ σ (refl {x = γ})) (ap (λ ω → horizontal-concat ω γ) σ)
right-unit-law-z-concat-Id³ refl = refl

ap-y-concat-Id³ :
  {l : Level} {A : UU l} {x y : A} {p q r : Id x y} {α β : Id p q}
  {γ δ : Id q r} {σ σ' : Id α β} (s : Id σ σ') {τ τ' : Id γ δ} (t : Id τ τ') →
  Id (y-concat-Id³ σ τ) (y-concat-Id³ σ' τ')
ap-y-concat-Id³ s t = ap-horizontal-concat s t

ap-z-concat-Id³ :
  {l : Level} {A : UU l} {x y z : A} {p q : Id x y} {u v : Id y z}
  {α β : Id p q} {γ δ : Id u v} {σ σ' : Id α β} {τ τ' : Id γ δ} →
  Id σ σ' → Id τ τ' → Id (z-concat-Id³ σ τ) (z-concat-Id³ σ' τ')
ap-z-concat-Id³ s t = ap-binary z-concat-Id³ s t

interchange-x-y-concat-Id³ :
  {l : Level} {A : UU l} {x y : A} {p q r : Id x y} {α β γ : Id p q}
  {δ ε ζ : Id q r} (σ : Id α β) (τ : Id β γ) (υ : Id δ ε) (ϕ : Id ε ζ) →
  Id ( y-concat-Id³ (x-concat-Id³ σ τ) (x-concat-Id³ υ ϕ))
     ( x-concat-Id³ (y-concat-Id³ σ υ) (y-concat-Id³ τ ϕ))
interchange-x-y-concat-Id³ = interchange-Id²

interchange-x-z-concat-Id³ :
  {l : Level} {A : UU l} {x y z : A} {p q : Id x y} {u v : Id y z}
  {α β γ : Id p q} {δ ε ζ : Id u v} (σ : Id α β) (τ : Id β γ) (υ : Id δ ε)
  (ϕ : Id ε ζ) →
  Id ( z-concat-Id³ (x-concat-Id³ σ τ) (x-concat-Id³ υ ϕ))
     ( x-concat-Id³ (z-concat-Id³ σ υ) (z-concat-Id³ τ ϕ))
interchange-x-z-concat-Id³ refl τ refl ϕ = refl

interchange-y-z-concat-Id³ :
  {l : Level} {A : UU l} {x y z : A} {p q r : Id x y} {u v w : Id y z}
  {α β : Id p q} {γ δ : Id q r} {ε ζ : Id u v} {η θ : Id v w}
  (σ : Id α β) (τ : Id γ δ) (υ : Id ε ζ) (ϕ : Id η θ) →
  Id ( ( z-concat-Id³ (y-concat-Id³ σ τ) (y-concat-Id³ υ ϕ)) ∙
       ( interchange-Id² β δ ζ θ))
     ( ( interchange-Id² α γ ε η) ∙
       ( y-concat-Id³ (z-concat-Id³ σ υ) (z-concat-Id³ τ ϕ)))
interchange-y-z-concat-Id³ refl refl refl refl = inv right-unit

source-coherence-interchange-Id³ :
  {l : Level} {X : UU l} {x y z : X} {p q r : Id x y} {u v w : Id y z}
  {α β γ : Id p q} {δ ε ζ : Id q r} {η θ ι : Id u v} {κ μ ν : Id v w}
  (A : Id α β) (B : Id β γ) (C : Id δ ε) (D : Id ε ζ) (E : Id η θ) (F : Id θ ι)
  (G : Id κ μ) (H : Id μ ν) →
  Id ( ( ( z-concat-Id³
           ( y-concat-Id³ (x-concat-Id³ A B) (x-concat-Id³ C D))
           ( y-concat-Id³ (x-concat-Id³ E F) (x-concat-Id³ G H))) ∙
         ( interchange-Id² γ ζ ι ν)))
     ( ( interchange-Id² α δ η κ) ∙
       ( x-concat-Id³
         ( y-concat-Id³ (z-concat-Id³ A E) (z-concat-Id³ C G))
         ( y-concat-Id³ (z-concat-Id³ B F) (z-concat-Id³ D H))))
source-coherence-interchange-Id³ {l} {X} {x} {y} {z} {p} {q} {r} {u} {v} {w}
  {α} {β} {γ} {δ} {ε} {ζ} {η} {θ} {ι} {κ} {μ} {ν} A B C D E F G H =
  ( interchange-y-z-concat-Id³ (A ∙ B) (C ∙ D) (E ∙ F) (G ∙ H)) ∙
  ( ( ap ( concat
           ( interchange-Id² α δ η κ)
           ( horizontal-concat γ ι ∙ horizontal-concat ζ ν))
         ( ( ap-horizontal-concat
             ( interchange-x-z-concat-Id³ A B E F)
             ( interchange-x-z-concat-Id³ C D G H)) ∙
           ( interchange-x-y-concat-Id³
             ( z-concat-Id³ A E)
             ( z-concat-Id³ B F)
             ( z-concat-Id³ C G)
             ( z-concat-Id³ D H)))))

target-coherence-interchange-Id³ :
  {l : Level} {X : UU l} {x y z : X} {p q r : Id x y} {u v w : Id y z}
  {α β γ : Id p q} {δ ε ζ : Id q r} {η θ ι : Id u v} {κ μ ν : Id v w}
  (A : Id α β) (B : Id β γ) (C : Id δ ε) (D : Id ε ζ) (E : Id η θ) (F : Id θ ι)
  (G : Id κ μ) (H : Id μ ν) →
  Id ( ( ( z-concat-Id³
           ( y-concat-Id³ (x-concat-Id³ A B) (x-concat-Id³ C D))
           ( y-concat-Id³ (x-concat-Id³ E F) (x-concat-Id³ G H))) ∙
         ( interchange-Id² γ ζ ι ν)))
     ( ( interchange-Id² α δ η κ) ∙
       ( x-concat-Id³
         ( y-concat-Id³ (z-concat-Id³ A E) (z-concat-Id³ C G))
         ( y-concat-Id³ (z-concat-Id³ B F) (z-concat-Id³ D H))))
target-coherence-interchange-Id³ {l} {X} {x} {y} {z} {p} {q} {r} {u} {v} {w}
  {α} {β} {γ} {δ} {ε} {ζ} {η} {θ} {ι} {κ} {μ} {ν} A B C D E F G H =
  ( ( ap
      ( concat'
        ( horizontal-concat (α ∙ δ) (η ∙ κ))
        ( interchange-Id² γ ζ ι ν))
      ( ap-z-concat-Id³
        ( interchange-x-y-concat-Id³ A B C D)
        ( interchange-x-y-concat-Id³ E F G H))) ∙
    ( ( ap
        ( concat'
          ( horizontal-concat (α ∙ δ) (η ∙ κ))
          ( interchange-Id² γ ζ ι ν))
        ( interchange-x-z-concat-Id³
          ( y-concat-Id³ A C)
          ( y-concat-Id³ B D)
          ( y-concat-Id³ E G)
          ( y-concat-Id³ F H))) ∙
      ( ( assoc
          ( z-concat-Id³ (y-concat-Id³ A C) (y-concat-Id³ E G))
          ( z-concat-Id³ (y-concat-Id³ B D) (y-concat-Id³ F H))
          ( interchange-Id² γ ζ ι ν)) ∙
        ( ( ap ( concat
                 ( z-concat-Id³ (y-concat-Id³ A C) (y-concat-Id³ E G))
                 ( horizontal-concat γ ι ∙ horizontal-concat ζ ν))
               ( interchange-y-z-concat-Id³ B D F H)) ∙
          ( ( inv
              ( assoc
                ( z-concat-Id³ (y-concat-Id³ A C) (y-concat-Id³ E G))
                ( interchange-Id² β ε θ μ)
                ( y-concat-Id³ (z-concat-Id³ B F) (z-concat-Id³ D H)))) ∙
            ( ap
              ( concat'
                ( horizontal-concat (α ∙ δ) (η ∙ κ))
                ( y-concat-Id³ (z-concat-Id³ B F) (z-concat-Id³ D H)))
              ( interchange-y-z-concat-Id³ A C E G))))))) ∙
  ( assoc
    ( interchange-Id² α δ η κ)
    ( y-concat-Id³ (z-concat-Id³ A E) (z-concat-Id³ C G))
    ( y-concat-Id³ (z-concat-Id³ B F) (z-concat-Id³ D H)))
  
coherence-interchange-Id³ :
  {l : Level} {X : UU l} {x y z : X} {p q r : Id x y} {u v w : Id y z}
  {α β γ : Id p q} {δ ε ζ : Id q r} {η θ ι : Id u v} {κ μ ν : Id v w}
  (A : Id α β) (B : Id β γ) (C : Id δ ε) (D : Id ε ζ) (E : Id η θ) (F : Id θ ι)
  (G : Id κ μ) (H : Id μ ν) →
  Id ( source-coherence-interchange-Id³ A B C D E F G H)
     ( target-coherence-interchange-Id³ A B C D E F G H)
coherence-interchange-Id³
  {l} {X} {x} {y} {z} {p} {.p} {.p} {u} {.u} {.u} {refl} {.refl} {.refl} {refl}
  {.refl} {.refl} {refl} {.refl} {.refl} {refl} {.refl} {.refl} refl refl refl
  refl refl refl refl refl = refl

--------------------------------------------------------------------------------
