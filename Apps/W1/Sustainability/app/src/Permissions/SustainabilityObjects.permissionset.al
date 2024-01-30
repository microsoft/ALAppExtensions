namespace Microsoft.Sustainability;

using Microsoft.Sustainability.Journal;
using Microsoft.Sustainability.Ledger;
using Microsoft.Sustainability.Calculation;
using Microsoft.Sustainability.Posting;
using Microsoft.Sustainability.Account;
using Microsoft.Sustainability.Setup;

permissionset 6210 "Sustainability - Objects"
{
    Caption = 'Sustainability - Objects';
    Access = Internal;
    Assignable = false;

    Permissions =
        table "Sustainability Account" = X,
        table "Sustain. Account Category" = X,
        table "Sustain. Account Subcategory" = X,
        table "Sustainability Jnl. Template" = X,
        table "Sustainability Jnl. Batch" = X,
        table "Sustainability Jnl. Line" = X,
        table "Sustainability Ledger Entry" = X,
        table "Sustainability Setup" = X,
        page "Chart of Sustain. Accounts" = X,
        page "Collect Amount from G/L Entry" = X,
        page "G/L Accounts Subform" = X,
        page "Sustainability Account Card" = X,
        page "Sustain. Account Categories" = X,
        page "Sustain. Category FactBox" = X,
        page "Sustain. Subcategory FactBox" = X,
        page "Sustainability Account List" = X,
        page "Sustain. Account Subcategories" = X,
        page "Sustainability Jnl. Templates" = X,
        page "Sustainability Jnl. Temp. List" = X,
        page "Sustainability Jnl. Batches" = X,
        page "Sustainability Journal" = X,
        page "Recurring Sustainability Jnl." = X,
        page "Sustainability Ledger Entries" = X,
        page "Sustainability Setup" = X,
        codeunit "Sustainability Account Mgt." = X,
        codeunit "Sustainability Journal Mgt." = X,
        codeunit "Sustainability Jnl.-Post" = X,
        codeunit "Sustainability Recur Jnl.-Post" = X,
        codeunit "Sustainability Post Mgt" = X,
        codeunit "Sustainability Jnl.-Check" = X,
        codeunit "Sustainability Calculation" = X,
        codeunit "Sustainability Calc. Mgt." = X;
}