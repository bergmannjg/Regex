import Batteries.Data.Nat.Lemmas
import Batteries.Data.Fin.Lemmas
import Init.Data.Int.Lemmas
import Batteries.Data.List.Basic
import Batteries.Data.List.Lemmas

import Regex.Data.Nat.Basic

namespace List

theorem singleton_val_of (a : α) (arr : List α) (h1 : arr = [a]) (h2 : 0 < List.length arr)
    : List.get arr ⟨0, h2⟩ = a  := by
  simp_all [List.get]

theorem singleton_val (a : α) (h : 0 < List.length [a])
    : List.get [a] ⟨0, h⟩ = a  := by
  simp [List.singleton_val_of a [a] (by simp) h]

theorem get_of_fun_eq {l1 l2 : List α} {f : List α → List α} (h : f l1 = f l2)
  (n : Fin (f l1).length) : (f l1).get n = (f l2).get ⟨n, h ▸ n.2⟩ :=
  List.get_of_eq h n

theorem eq_of_dropLast_eq_last_eq {l1 l2 : List α} (hd : List.dropLast l1 = List.dropLast l2)
  (hl1 : l1.length - 1 < l1.length) (hl2 : l2.length - 1 < l2.length)
  (heq : List.get l1 ⟨l1.length - 1, hl1⟩  = List.get l2 ⟨l2.length - 1, hl2⟩) : l1 = l2 :=
  have hdl : l1.dropLast.length = l2.dropLast.length := by rw [hd]
  have hn1 : 0 < l1.length := Nat.zero_lt_of_lt hl1
  have hn2 : 0 < l2.length := Nat.zero_lt_of_lt hl2
  have hl : l1.length = l2.length := by
    have h1 : l1.dropLast.length = l1.length - 1 := List.length_dropLast l1
    have h2 : l2.dropLast.length = l2.length - 1 := List.length_dropLast l2
    rw [hdl, h2] at h1
    simp [Nat.pred_inj hn1 hn2 h1.symm]
  List.ext_get hl fun n h1 h2 =>
    if hx1 : n < l1.dropLast.length then by
      have hx2 : n < l2.dropLast.length := Nat.lt_of_lt_of_eq hx1 hdl
      have hy1 : l1.dropLast.get ⟨n, hx1⟩ = l1.get ⟨n, h1⟩ := List.getElem_dropLast l1 n hx1
      have hy2 : l2.dropLast.get ⟨n, hx2⟩ = l2.get ⟨n, h2⟩ := List.getElem_dropLast l2 n hx2
      have hy3 : l1.dropLast.get ⟨n, hx1⟩ = l2.dropLast.get ⟨n, hx2⟩ := List.get_of_fun_eq hd ⟨n, hx1⟩
      rw [hy3, hy2] at hy1
      rw [hy1]
    else by
      rw [List.length_dropLast l1] at hx1
      simp [Nat.le_of_not_gt] at hx1
      have hn1 : n = l1.length - 1 := by
        simp [Nat.eq_pred_of_le_of_lt_succ hn1 hx1 h1]
      have hn2 : n = l2.length - 1 := by
        have hx2 : List.length l2 - 1 ≤ n := by
          rw [hl] at hx1
          simp [hx1]
        simp_all [Nat.eq_pred_of_le_of_lt_succ hn2 hx2 h2]
      simp [← hn1, ← hn2] at heq
      simp [heq]

theorem get_last_of_concat {l : List α} (h : (l ++ [last]).length - 1 < (l ++ [last]).length)
    : List.get (l ++ [last]) ⟨(l ++ [last]).length - 1, h⟩ = last  := by
  simp [List.get_last _]

theorem eq_succ_of_tail_nth {head : α} {tail : List α} (data : List α) (h1 : n+1 < data.length)
  (h2 : data = head :: tail) (h3 : n < tail.length)
    : tail.get ⟨n, h3⟩ = data.get ⟨n+1, h1⟩ := by
  cases h2
  have h : (head :: tail).get ⟨n+1, h1⟩ = tail.get ⟨n, h3⟩ := List.get_cons_succ
  exact h.symm

theorem eq_succ_of_tail_nth_pred {head : α} {tail : List α} (data : List α) (h0 : n ≠ 0)
  (h1 : n < data.length) (h2 : data = head :: tail) (h3 : n - 1 < tail.length)
    : tail.get ⟨n - 1, h3⟩ = data.get ⟨n, h1⟩ := by
  have hps : n - 1 + 1 = n := Nat.succ_pred (by simp_all)
  have hpl : n - 1 + 1 < data.length := by simp only [hps, h1]
  have : data.get ⟨n, h1⟩ = data.get ⟨n - 1 + 1, hpl⟩ := by simp_all
  rw [this]
  exact List.eq_succ_of_tail_nth data hpl h2 h3

/- see Mathlib/Data/List/Chain.lean -/
theorem chain_split {a b : α} {l₁ l₂ : List α} :
    Chain R a (l₁ ++ b :: l₂) ↔ Chain R a (l₁ ++ [b]) ∧ Chain R b l₂ := by
  induction l₁ generalizing a with
  | nil => simp
  | cons x l₁ IH => simp only [cons_append, chain_cons, and_assoc, IH]

/- see Mathlib/Data/List/Chain.lean -/
theorem chain_append_cons_cons {a b c : α} {l₁ l₂ : List α} :
    Chain R a (l₁ ++ b :: c :: l₂) ↔ Chain R a (l₁ ++ [b]) ∧ R b c ∧ Chain R c l₂ := by
  rw [chain_split, chain_cons]

/- see Mathlib/Data/List/Chain.lean -/
theorem chain_iff_get {R} : ∀ {a : α} {l : List α}, Chain R a l ↔
    (∀ h : 0 < length l, R a (get l ⟨0, h⟩)) ∧
      ∀ (i : Nat) (h : i < l.length - 1),
        R (get l ⟨i, by omega⟩) (get l ⟨i+1, by omega⟩)
  | a, [] => iff_of_true (by simp) ⟨fun h => by simp at h, fun _ h => by simp at h⟩
  | a, b :: t => by
    rw [chain_cons, @chain_iff_get _ _ _ t]
    constructor
    · rintro ⟨R, ⟨h0, h⟩⟩
      constructor
      · intro _
        exact R
      intro i w
      cases i
      · apply h0
      · rename_i i
        exact h i (by simp only [length_cons] at w; omega)
    rintro ⟨h0, h⟩; constructor
    · apply h0
      simp
    constructor
    · apply h 0
    intro i w
    exact h (i+1) (by simp only [length_cons]; omega)
