# Differences between LA and RA processing 

The quick guide walks you through an LA case. For some reason, RA needs a bit more extra processing.
This is why we are expecting the RA to cause more problems. 

It is easier to understand first the LA processing and then understand the RA. 
Look at the table below: 

| LA (EPI)            | RA (EPI)                             |
|:--------------------|:-------------------------------------|
| Copy landmark files | Copy landmark files                  |
|                     | **Outline RAA in mesh**              |
| UAC Stage 1         | UAC Stage 1                          |
| Laplace solves (1)  | Laplace solves (1)                   |
| UAC Stage 2a        | UAC Stage 2a                         |
| Laplace Solves (2)  | Laplace Solves (2)                   |
| UAC Stage 2b        | UAC Stage 2b                         |
|                     | **Scalar Mapping** |
| Fibre Mapping       | Fibre Mapping                        |


