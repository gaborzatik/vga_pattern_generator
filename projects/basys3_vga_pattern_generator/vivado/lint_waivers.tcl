# RTL linter waivers for the Basys3 VGA pattern generator project.
#
# These waivers intentionally target the generated Clocking Wizard wrapper
# hierarchy. The IP emits optional outputs and *_unused sink signals that are
# expected for this configuration and would otherwise create recurring
# ASSIGN-5/ASSIGN-6 noise during lint runs.

create_waiver -type LINT \
    -id ASSIGN-5 \
    -rtl_hierarchy clk_wiz_pixel_clk_wiz \
    -description "Suppress expected Clocking Wizard generated wrapper ASSIGN-5 warnings for unused optional outputs."

create_waiver -type LINT \
    -id ASSIGN-6 \
    -rtl_hierarchy clk_wiz_pixel_clk_wiz \
    -description "Suppress expected Clocking Wizard generated wrapper ASSIGN-6 warnings for *_unused sink signals and optional outputs."
