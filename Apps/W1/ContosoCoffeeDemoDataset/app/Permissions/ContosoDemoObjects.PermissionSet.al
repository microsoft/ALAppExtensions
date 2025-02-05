
permissionset 4768 "Contoso Demo - Objects"
{
    Access = Public;
    Assignable = false;

    Permissions = table "EService Demo Data Setup" = X,
                  table "FA Module Setup" = X,
                  table "Human Resources Module Setup" = X,
                  table "Jobs Module Setup" = X,
                  table "Manufacturing Module Setup" = X,
                  table "Service Module Setup" = X,
                  table "Warehouse Module Setup" = X,
                  table "Contoso Coffee Demo Data Setup" = X,
                  table "Contoso Demo Data Module" = X,
                  table "Contoso Module Dependency" = X,
                  page "Contoso Coffee Demo Data" = X,
                  page "Contoso Demo Tool" = X,
                  page "Contoso Modules Part" = X;
}
