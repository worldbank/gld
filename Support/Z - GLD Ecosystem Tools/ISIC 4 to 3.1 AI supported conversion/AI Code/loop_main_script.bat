@echo off
for /l %%i in (1,1,100) do (
    python main_script.py ISIC4_ISIC31.csv ISIC_31_4digit_long.xlsx ISIC_4_4digit_long.xlsx Runs/run_%%i.xlsx
)
pause