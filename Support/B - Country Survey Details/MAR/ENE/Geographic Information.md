# Geographic Information

## Region changes
In 2015, Morocco underwent a comprehensive reorganization of its regional boundaries, changing from 16 to 12 regions (see map below). This reorganization was not a mere adjustment of a few regions but a complete overhaul, affecting the entire country with the exception of the Ed Dakhla-Oued ed Dahab region, which retained its provincial composition. This significant change was proposed by the Commission consultative de la régionalisation in 2010, aiming to foster decentralization and enhance regional autonomy across Morocco.

![Map](Utilities/Morocco_map.PNG)

In the Morocco ENE survey data, the region codes have been altered significantly with no relation to the prior codes. To ensure comparability over time, users are advised to use the `subnatid1_prev` variable beginning with the 2015 data when the new regional classification was adopted. 

Below is a summary table of the new regions, highlighting their source regions or provinces and the specific changes made:

| New Region               | Source Regions/Provinces                            | Changes Made                                                                                                         |
|--------------------------|-----------------------------------------------------|----------------------------------------------------------------------------------------------------------------------|
| Tanger-Tétouan-Al Hoceima| Tanger-Tétouan, Al Hoceima, Ouezzane                 | Annexed Al Hoceima and Ouezzane provinces to Tanger-Tétouan region.                                                 |
| Oriental                 | Includes Driouch, Guercif                           | Annexed Driouch and Guercif provinces.                                                                               |
| Fès-Meknès               | Fès-Boulemane, Part of Meknès-Tafilalet, Taounate, Taza | Merged Fès-Boulemane region with the northern part of Meknès-Tafilalet region and annexed Taounate and Taza provinces.|
| Rabat-Salé-Kénitra       | Parts of Fès-Boulemane and Meknès-Tafilalet          | Formed by merging parts of Fès-Boulemane and Meknès-Tafilalet regions.                                               |
| Béni Mellal-Khénifra     | Tadla-Azilal, Fqih Ben Salah, Khouribga, Part of Khénifra | Annexed Fqih Ben Salah, Khouribga, and part of Khénifra provinces to Tadla-Azilal region.                             |
| Casablanca-Settat        | Grand Casablanca, Chaouia-Ouardigha, El Jadida      | Merged Grand Casablanca and Chaouia-Ouardigha regions and annexed El Jadida province.                                |
| Marrakech-Safi           | Marrakech-Tensift-Al Haouz, Safi                    | Annexed Safi province to Marrakech-Tensift-Al Haouz region.                                                          |
| Drâa-Tafilalet           | Errachidia, Ouarzazate, Zagora, Part of Khénifra    | Formed from provinces taken from Meknès-Tafilalet and Souss-Massa-Draâ regions, and part of Khénifra province.       |
| Souss-Massa              | Souss-Massa-Draâ, Tata                              | Annexed Tata province to Souss-Massa-Draâ region.                                                                    |
| Guelmim-Oued Noun        | Guelmim-Es-Semara, Sidi Ifni                        | Annexed Sidi Ifni province to Guelmim-Es-Semara region.                                                              |
| Laâyoune-Saguia al Hamra | Laâyoune-Boujdour-Sakia El Hamra, Es-Semara          | Annexed Es-Semara province to Laâyoune-Boujdour-Sakia El Hamra region.                                               |
| Ed Dakhla-Oued ed Dahab  | Equivalent to former Oued Ed-Dahab-Lagouira region   | No change, equivalent to the former Oued Ed-Dahab-Lagouira region.                                                   |

## Constructing region variable (`subnatid1`) in the dataset
The region variable is not available in all the raw survey data we received. We used a set of separate datasets that map each primary sampling unit (PSU) to their regions. With the PSU information available in all the raw survey data, merging this PSU-level data to the raw dataset allowed us to construct the region variable. 

With sampling frames changing over time, an important intermediate step involved identifying the correct sampling frame used for each survey. The set of PSU codes for each sampling frame is unique, and by using this information, we can determine the sampling frame used in the survey by examining the matches in a sampling frame's list of PSU and that in a given survey round. Following this process, we were able to determine the sampling frame used in each survey as follows:

| Survey Years            | Sampling Frame Year                          |
|-------------------------|----------------------------------------------|
| 2000 - 2005             | 1995 Sampling Frame                          |
| 2006 - 2014             | 2005 Sampling Frame                          |
| 2015 - 2018             | 2015 Sampling Frame                          |

However, the regions identified by this process may not be consistent with the region variable when it is available in the survey data (see screenshot below as an example from the 2007 ENE). Since our goal was to provide region information using a consistent source in as many surveys as possible, we decided to keep the information from the PSU-level data. 

![Map](Utilities/region_mismatch.png)


