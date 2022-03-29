permissionset 633 "DataArchive - Objects"
{
    Assignable = false;
    Access = Public;
    Caption = 'Data Archive - Objects';

    Permissions = codeunit "Data Archive Db Subscriber" = X,
                  codeunit "Data Archive Export to CSV" = X,
                  codeunit "Data Archive Export To Excel" = X,
                  page "Data Archive - New Archive" = X,
                  page "Data Archive List" = X,
                  page "Data Archive Table List" = X,
                  page "Data Archive Table ListPart" = X,
                  table "Data Archive Media Field" = X,
                  table "Data Archive Table" = X,
                  table "Data Archive" = X;
}
