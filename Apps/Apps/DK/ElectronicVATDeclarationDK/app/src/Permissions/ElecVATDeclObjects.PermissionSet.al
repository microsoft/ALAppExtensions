namespace Microsoft.Finance.VAT.Reporting;

permissionset 13610 "Elec. VAT Decl. Objects"
{
    Access = Public;
    Assignable = false;

    Permissions = codeunit "Elec. VAT Decl. Check Builder" = X,
                  codeunit "Elec. VAT Decl. Submit Builder" = X,
                  codeunit "Elec. VAT Decl. Period Builder" = X,
                  codeunit "Elec. VAT Decl. Http Comm." = X,
                  codeunit "Elec. VAT Decl. Http Response" = X,
                  codeunit "Elec. VAT Decl. Create" = X,
                  codeunit "Elec. VAT Decl. Cryptography" = X,
                  codeunit "Elec. VAT Decl. Get Periods" = X,
                  codeunit "Elec. VAT Decl. Install" = X,
                  codeunit "Elec. VAT Decl. SKAT API" = X,
                  codeunit "Elec. VAT Decl. Submit" = X,
                  codeunit "Elec. VAT Decl. Validate" = X,
                  codeunit "Elec. VAT Decl. Xml" = X,
                  codeunit "Elec. VAT Decl. Archiving" = X,
                  page "Elec. VAT Decl. Setup" = X,
                  page "Elec. VAT Decl. Comm. Logs" = X,
                  table "Elec. VAT Decl. Parameters" = X,
                  table "Elec. VAT Decl. Communication" = X,
                  table "Elec. VAT Decl. Setup" = X;
}