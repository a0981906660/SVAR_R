# R Notebook

Inside this directory, there are 6 identifications listed in 6 `.ipynb` respectively.

These identification conditions are named after `v5i1-seed`,

where:

1. `v4i1` means: the non-recursive identification condition for 4-variable SVAR model with "mp, hs, hd, sp" ordering.

2. `v4i1-chol` means: the Wold ordering identification condition for 4-variable SVAR model with "mp, hs, hd, sp" ordering.

3. `v5i1-unif92746` means: the non-recursive identification condition for 5-variable SVAR model with "mp, hs, hd, expectation, sp" ordering. And the housing price has no shortrun effect on sentiment.

4. `v5i2-norm175366` means: the non-recursive identification condition for 5-variable SVAR model with "mp, expectation, hs, hd, sp" ordering.

5. `v5i3-chol` means: the Wold ordering identification condition for 5-variable SVAR model with "mp, hs, hd, sp, expectation" ordering.

5. `v5i3-chol` means: the Wold ordering identification condition for 5-variable SVAR model with "mp, hs, hd, expectation, sp" ordering.


### Notation

`mp` : monetary policy shock, obtained by interest rate

`hs` : housing supply shock, obtained by number of permits

`hd` : housing demand shock, obtained by housing loan

`sp` : housing speculation shock, obtained by 信義房價指數

`expectation` : housing price expectation shock, obtained by sentiment index contructed by news text