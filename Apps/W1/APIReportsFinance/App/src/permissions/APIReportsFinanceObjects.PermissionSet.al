namespace Microsoft.API.FinancialManagement;

permissionset 30300 "API Reports Finance - Objects"
{
    Assignable = false;
    Access = Internal;

    Permissions = Page "API Finance - Acc Periods" = X,
                  Page "API Finance - Business Unit" = X,
                  Page "API Finance - Dimension Values" = X,
                  Page "API Finance - Dim Set Entries" = X,
                  Page "API Finance - GL Account" = X,
                  Page "API Finance - GL Budgets" = X,
                  Query "API Finance - GL Entry" = X,
                  Page "API Finance - Global Settings" = X,
                  Query "API Fin - Cust Ledg Entry" = X,
                  Query "API Fin - Dtld Cust Ledg Entry" = X,
                  Query "API Fin - Dtld Vend Ledg Entry" = X,
                  Query "API Fin - Vend Ledg Entry" = X;
}