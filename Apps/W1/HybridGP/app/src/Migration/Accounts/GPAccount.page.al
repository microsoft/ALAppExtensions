#if not CLEAN26
namespace Microsoft.DataMigration.GP;

page 4090 "GP Account"
{
    PageType = Card;
    SourceTable = "GP Account";
    DeleteAllowed = false;
    InsertAllowed = false;
    Caption = 'Account Table';
    PromotedActionCategories = 'Related Entities';
    UsageCategory = None;
    ObsoleteState = Pending;
    ObsoleteReason = 'Removing the GP staging table pages because they cause confusion and should not be used.';
    ObsoleteTag = '26.0';

    layout
    {
        area(content)
        {
            group(General)
            {
                field(AcctNum; Rec.AcctNum)
                {
                    ApplicationArea = All;
                    ToolTip = 'Account Number';
                }
                field(AcctIndex; Rec.AcctIndex)
                {
                    ApplicationArea = All;
                    ToolTip = 'Account Index';
                }
                field(Name; Rec.Name)
                {
                    ApplicationArea = All;
                    ToolTip = 'Account Name';
                }
                field(SearchName; Rec.SearchName)
                {
                    ApplicationArea = All;
                    ToolTip = 'Search Name';
                }
                field(AccountCategory; Rec.AccountCategory)
                {
                    ApplicationArea = All;
                    ToolTip = 'Account Category';
                }
                field(IncomeBalance; Rec.IncomeBalance)
                {
                    ApplicationArea = All;
                    ToolTip = 'Income Balance';
                }
                field(DebitCredit; Rec.DebitCredit)
                {
                    ApplicationArea = All;
                    ToolTip = 'Debit or Credit';
                }
                field(Active; Rec.Active)
                {
                    ApplicationArea = All;
                    ToolTip = 'Active';
                }
                field(DirectPosting; Rec.DirectPosting)
                {
                    ApplicationArea = All;
                    ToolTip = 'Direct Posting';
                }
                field(AccountSubcategoryEntryNo; Rec.AccountSubcategoryEntryNo)
                {
                    ApplicationArea = All;
                    ToolTip = 'Account Subcategory Entry Number';
                }
                field(AccountType; Rec.AccountType)
                {
                    ApplicationArea = All;
                    ToolTip = 'Account Type';
                }
            }
        }
    }
}
#endif