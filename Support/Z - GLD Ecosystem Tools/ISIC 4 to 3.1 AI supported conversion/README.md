# ISIC 4 to ISIC 3.1 AI Supported Conversion

## The challenge of classifying activities over time

Classifying job types accurately is essential for understanding labor market trends. These classifications help policymakers tailor policies to support sectors most in need. As economies grow and new industries appear, job roles become more complex, making precise classifications crucial for tracking employment changes and addressing sector-specific challenges. For example, rapid technological advances and the digital transformation of commerce require updates to job categories. However, job classifications often lag behind industry innovations, leading to discrepancies in labor data that can affect policy decisions. Accurate and current job classifications enable policymakers to allocate resources effectively and design initiatives that help the labor market adapt. 

The main challenge with job classifications is their frequent updates to reflect economic changes. This disrupts the continuity of labor market statistics, as new job codes may not align with old ones. For instance, in the technology sector, roles like data scientists and software engineers have emerged rapidly, replacing older roles such as "computer programmers" and "network administrators". 

If classification systems are not updated promptly, it can lead to misleading statistics that do not accurately represent the current job market. This misalignment complicates efforts to track job growth, as new job titles can obscure real employment trends. It also affects wage data, making it difficult to compare salaries over time due to job reclassification discrepancies.

## Current approach

Currently, we rely on the correspondence tables published by the United Nations (UN) for the International Standard Industrial Classification (ISIC) and the International Labour Organisation (ILO) for the International Standard Classification of Occupations. These classifications, however, only provide a list of correspondences. For example, ISIC revision code `0322 - Freshwater acquaculture` officially corresponds to codes `0122 - Other animal farming; production of animal products n.e.c.` and `0502 - Aquaculture`. The correspondece table does not weight the options and thus the (seemingly) least intrusive is to assign the same probability to both options. That is, a person with a code `0322` in ISIC 4 should be assigned to `0122` with 50% probabiltiy or to `0502` with 50%. [This is what our current tool does](https://github.com/worldbank/gld/tree/main/Support/Z%20-%20GLD%20Ecosystem%20Tools/ISIC%20ISCO%20conversion%20tool).

However, on reading the descriptions, it becomes evident that the activity covered in `0322` that refers to `0122` is the raising of frogs and reptiles, `0502` refers to the economically much larger field of the production of molluscs and fish. Thus, being less intrusive would probably would mean assigning a probability much larger to `0502` than to `0122`. The issue with this approach is that reading and comparing each entry of the detailed four-digit codes is very time-intensive. 

## AI supported approach

The advent of accessible artificial intelligence (AI) allows us to leverage AI models to read the code descriptions and make inferences on our behalf. A team of four students from the California Polytechnic State University, San Luis Obispo, has been working on a pilot to leverage this process. The details of their work can be seen in their paper on classification systems](Advancing%20Job%20Classification%20Systems%20-%20Leveraging%20AI%20to%20Enhance%20Historical%20Mapping%20Between%20ISIC%20revisions.pdf) and the GLD team is thanful for their dedication in creating the pilot. The code to run the AI supported along with instructions can be found in the `AI Code` folder.

## Example implementation

The code in file [`Code to assign probabilities.do`](Code%20to%20assign%20probabilities.do) contains an example of how to implement the process based on loading a GLD harmonized file (or files) with information from ISIC version 4 and converting the information to the codes of ISIC revision 3.1.
