# Topic: High-Energy Physics Lattice Field Theory (from hep-lat)

## Filtering Policy (INCLUSIVE)
- **Keep all** genuine lattice field theory papers:
  - Lattice QCD spectrum, hadron structure, decay constants, form factors, g-2, rare decays
  - Scale setting, renormalization, finite-volume/QED/isospin-breaking effects
  - Chiral gauge theories, BSM lattice (composite Higgs, dark QCD, SUSY on lattice)
  - Lattice algorithms, HMC/machine learning, tensor networks, quantum simulation of gauge theories
- **Exclude**:
  - Only exclude brief conference proceedings (e.g., PoS LATTICE proceedings) unless they announce major flagship collaboration results.

## Highlight Selection Criteria
Prioritize papers with physical-point ensembles and controlled continuum/chiral extrapolations, major collaboration releases (RBC-UKQCD, MILC, CLS, ETM, JLQCD, BMW, HotQCD, etc.), or methodological breakthroughs in algorithms/chiral fermions/quantum simulation.

## Deep-Dive Requirements
For each highlighted paper, extract:
1. Physics goal & why prior calculations were limited.
2. Lattice setup: fermion action (domain-wall, Wilson/clover, staggered, etc.), $N_f$, ensembles/lattice spacings, pion masses, and scale-setting/renormalization scheme.
3. Exact numerical results with statistical & systematic uncertainties (or sigma significance).
4. Public code / software mentions (Grid, QUDA, Chroma, etc.).

## Output Format & Language
- Language: Simplified Chinese.
- Sections:
  1. `# Lattice Field Theory Daily Digest` + date
  2. `## Frontier Trends` (2–4 sentences summarizing today's themes)
  3. `## Highlighted Papers` (deep dives)
  4. `## Other Lattice Papers` (one-line summary + link per remaining paper)