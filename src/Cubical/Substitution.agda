module Cubical.Substitution where

open import Basis
open import Cubical.DeMorgan
open import Cubical.Nominal

infix  6 _≔_

record Decl (Γ : Symbols) : Set where
  constructor _≔_
  field
    ▸i : String
    ▸φ : DeMorgan Γ
open Decl public

module Sub where
  infix  0 _≅_
  infixl 5 _≫=_
  infixr 5 _≫=≫_

  data Sub (Δ : Symbols) : (Γ : Symbols) → Set where
    []
      : Sub Δ []
    _∷_
      : ∀ {Γ}
      → (δ : Decl Δ)
      → (f : Sub Δ Γ)
      → Sub Δ (▸i δ ∷ Γ)
    loop
      : Sub Δ Δ
    _≫=≫_
      : ∀ {Γ Θ}
      → (f : Sub Θ Γ)
      → (g : Sub Δ Θ)
      → Sub Δ Γ

  mutual
    look : ∀ {Γ Δ} → Sub Δ Γ → Name Γ → DeMorgan Δ
    look [] (pt _ ())
    look (_ ≔ φ ∷ _) (pt _ (stop)) = φ
    look (_ ∷ f) (pt i (step _ _ ε)) = look f (pt i ε)
    look (loop) ε = var ε
    look (f ≫=≫ g) ε = look f ε ≫= g

    _≫=_ : ∀ {Γ Δ} → DeMorgan Γ → Sub Δ Γ → DeMorgan Δ
    var i ≫= f = look f i
    #0 ≫= f = #0
    #1 ≫= f = #1
    a ∨ b ≫= f = (a ≫= f) ∨ (b ≫= f)
    a ∧ b ≫= f = (a ≫= f) ∧ (b ≫= f)
    ¬ a ≫= f = ¬ (a ≫= f)

  record _≅_ {Δ Γ} (f g : Sub Δ Γ) : Set where
    no-eta-equality
    constructor ▸ext
    field
      ext : ∀ {i} → look f i 𝕀.≅ look g i
  open _≅_ public

  private
    ⊢coh-ρ-aux
      : ∀ {Γ} {a : DeMorgan Γ}
      → (a ≫= loop) ≡ a
    ⊢coh-ρ-aux {a = var _} = refl
    ⊢coh-ρ-aux {a = #0} = refl
    ⊢coh-ρ-aux {a = #1} = refl
    ⊢coh-ρ-aux {a = a ∨ b} = ≡.ap² _∨_ ⊢coh-ρ-aux ⊢coh-ρ-aux
    ⊢coh-ρ-aux {a = a ∧ b} = ≡.ap² _∧_ ⊢coh-ρ-aux ⊢coh-ρ-aux
    ⊢coh-ρ-aux {a = ¬ a} = ≡.ap ¬_ ⊢coh-ρ-aux

  ⊢coh-ρ
    : ∀ {Γ} {a : DeMorgan Γ}
    → (a ≫= loop) 𝕀.≅ a
  ⊢coh-ρ = 𝕀.idn ⊢coh-ρ-aux

  ⊢coh-ω-λ
    : ∀ {Γ Δ a b} {f : Sub Δ Γ}
    → a 𝕀.≅ b
    → a ≫= f 𝕀.≅ b ≫= f
  ⊢coh-ω-λ (𝕀.idn refl) = 𝕀.idn refl
  ⊢coh-ω-λ (𝕀.cmp q p) = 𝕀.cmp (⊢coh-ω-λ q) (⊢coh-ω-λ p)
  ⊢coh-ω-λ (𝕀.inv p) = 𝕀.inv (⊢coh-ω-λ p)
  ⊢coh-ω-λ 𝕀.∨-abs = 𝕀.∨-abs
  ⊢coh-ω-λ 𝕀.∨-ass = 𝕀.∨-ass
  ⊢coh-ω-λ 𝕀.∨-com = 𝕀.∨-com
  ⊢coh-ω-λ 𝕀.∨-dis = 𝕀.∨-dis
  ⊢coh-ω-λ 𝕀.∨-ide = 𝕀.∨-ide
  ⊢coh-ω-λ (𝕀.∨-rsp p q) = 𝕀.∨-rsp (⊢coh-ω-λ p) (⊢coh-ω-λ q)
  ⊢coh-ω-λ 𝕀.∨-uni = 𝕀.∨-uni
  ⊢coh-ω-λ 𝕀.∧-abs = 𝕀.∧-abs
  ⊢coh-ω-λ 𝕀.∧-ass = 𝕀.∧-ass
  ⊢coh-ω-λ 𝕀.∧-com = 𝕀.∧-com
  ⊢coh-ω-λ 𝕀.∧-dis = 𝕀.∧-dis
  ⊢coh-ω-λ 𝕀.∧-ide = 𝕀.∧-ide
  ⊢coh-ω-λ (𝕀.∧-rsp p q) = 𝕀.∧-rsp (⊢coh-ω-λ p) (⊢coh-ω-λ q)
  ⊢coh-ω-λ 𝕀.∧-uni = 𝕀.∧-uni
  ⊢coh-ω-λ 𝕀.¬-dis-∧ = 𝕀.¬-dis-∧
  ⊢coh-ω-λ 𝕀.¬-dis-∨ = 𝕀.¬-dis-∨
  ⊢coh-ω-λ 𝕀.¬-inv = 𝕀.¬-inv
  ⊢coh-ω-λ (𝕀.¬-rsp p) = 𝕀.¬-rsp (⊢coh-ω-λ p)
  ⊢coh-ω-λ 𝕀.¬-#0 = 𝕀.¬-#0
  ⊢coh-ω-λ 𝕀.¬-#1 = 𝕀.¬-#1

  ⊢coh-ω-ρ
    : ∀ {Γ Δ} a {f g : Sub Δ Γ}
    → f ≅ g
    → a ≫= f 𝕀.≅ a ≫= g
  ⊢coh-ω-ρ (var i) α = ext α {i}
  ⊢coh-ω-ρ #0 α = 𝕀.idn refl
  ⊢coh-ω-ρ #1 α = 𝕀.idn refl
  ⊢coh-ω-ρ (a ∨ b) α = 𝕀.∨-rsp (⊢coh-ω-ρ a α) (⊢coh-ω-ρ b α)
  ⊢coh-ω-ρ (a ∧ b) α = 𝕀.∧-rsp (⊢coh-ω-ρ a α) (⊢coh-ω-ρ b α)
  ⊢coh-ω-ρ (¬ a) α = 𝕀.¬-rsp (⊢coh-ω-ρ a α)

  private
    ⊢coh-α-aux
      : ∀ {Γ Δ Θ} a {f : Sub Δ Γ} {g : Sub Θ Δ}
      → a ≫= (f ≫=≫ g) ≡ (a ≫= f) ≫= g
    ⊢coh-α-aux (var _) = refl
    ⊢coh-α-aux #0 = refl
    ⊢coh-α-aux #1 = refl
    ⊢coh-α-aux (a ∨ b) = ≡.ap² _∨_ (⊢coh-α-aux a) (⊢coh-α-aux b)
    ⊢coh-α-aux (a ∧ b) = ≡.ap² _∧_ (⊢coh-α-aux a) (⊢coh-α-aux b)
    ⊢coh-α-aux (¬ a) = ≡.ap ¬_ (⊢coh-α-aux a)

  ⊢coh-α
    : ∀ {Γ Δ Θ} a {f : Sub Δ Γ} {g : Sub Θ Δ}
    → a ≫= (f ≫=≫ g) 𝕀.≅ (a ≫= f) ≫= g
  ⊢coh-α a = 𝕀.idn (⊢coh-α-aux a)

  ⊢coh-ω
    : ∀ {Γ Δ a b} {f g : Sub Δ Γ}
    → a 𝕀.≅ b
    → f ≅ g
    → a ≫= f 𝕀.≅ b ≫= g
  ⊢coh-ω {b = b} α β = 𝕀.cmp (⊢coh-ω-ρ b β) (⊢coh-ω-λ α)

  -- the setoid of nominal cubes
  set : Symbols → Symbols → Setoid
  set Δ Γ .Setoid.obj = Sub Δ Γ
  set Δ Γ .Setoid.hom = _≅_
  set Δ Γ .Setoid.idn₀ = ▸ext λ {i} → 𝕀.idn refl
  set Δ Γ .Setoid.cmp₀ β α = ▸ext λ {i} → 𝕀.cmp (ext β {i}) (ext α {i})
  set Δ Γ .Setoid.inv₀ α = ▸ext λ {i} → 𝕀.inv (ext α {i})

  -- the category of nominal cubes
  cat : Category
  ⟪ cat ⟫ .● = Symbols
  ⟪ cat ⟫ .∂ Γ Δ .● = Sub Γ Δ
  ⟪ cat ⟫ .∂ Γ Δ .∂ f g .● = f ≅ g
  ⟪ cat ⟫ .∂ Γ Δ .∂ f g .∂ α β = G.𝟘
  cat .idn₀ = loop
  cat .cmp₀ = _≫=≫_
  cat .idn₁ = ▸ext λ {i} → 𝕀.idn refl
  cat .cmp₁ β α = ▸ext λ {i} → 𝕀.cmp (ext β {i}) (ext α {i})
  cat .inv₁ α = ▸ext λ {i} → 𝕀.inv (ext α {i})
  cat .coh-λ = ▸ext λ {i} → 𝕀.idn refl
  cat .coh-ρ = ▸ext λ {i} → ⊢coh-ρ
  cat .coh-α {h = h} = ▸ext λ {i} → 𝕀.inv (⊢coh-α (look h i))
  cat .coh-ω β α = ▸ext λ {i} → ⊢coh-ω (ext β {i}) α
open Sub public
  hiding (module Sub)
  hiding (_≅_)
  hiding (⊢coh-α)
  hiding (⊢coh-ρ)
  hiding (⊢coh-ω-λ)
  hiding (⊢coh-ω-ρ)
  hiding (⊢coh-ω)
