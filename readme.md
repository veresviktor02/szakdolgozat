# Kalóriaszámláló alkalmazás

A Debreceni Egyetem Programervező Informatikus szakán
BSc szinten tanulok jelenleg.

Ez a projekt a szakdolgozatom témája.

### API használata

Ez a projekt egy publikusan és ingyenesen elérhető API-t használ a 
__CalorieNinjas__ fejlesztőitől.

Az alábbi linken található meg:
https://calorieninjas.com

Hogy működjenek a kérések az API felé, 
a gyökérkönyvtárban az _api.properties_ fájlba bele kell illeszteni az api kulcsot.
Ezt a fentebbi linken lehet beszerezni ingyen.

`API.key=(api_kulcs_helye)`

Ha tesztelni akarjátok a kéréseket, azt a weboldalon vagy a 
_requests/api_requests.http_ fájlban tudjátok.

Itt is meg kell adni az API kulcsot!

`@apiKey = (api_kulcs_helye)`