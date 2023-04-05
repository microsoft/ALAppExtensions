/// <summary>
/// Page Shpfy Customer Templates (ID 30108).
/// </summary>
page 30108 "Shpfy Customer Templates"
{
    Caption = 'Shopify Customer Templates';
    PageType = List;
    SourceTable = "Shpfy Customer Template";
    UsageCategory = None;

    layout
    {
        area(Content)
        {
            repeater(Group)
            {
                field(CountryCode; Rec."Country/Region Code")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the Country Code.';
                }
#if not CLEAN22
                field(CustomerTemlateCode; Rec."Customer Template Code")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies which customer template to use when creating unknown customers for this country. This template will only be used if the  field "Fix CustomerNo." is blank';
                    Visible = not NewTemplatesEnabled;
                    ObsoleteReason = 'Replaced by Customer Templ. Code';
                    ObsoleteState = Pending;
                    ObsoleteTag = '22.0';
                }
#endif
                field(CustomerTemplCode; Rec."Customer Templ. Code")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies which customer template to use when creating unknown customers for this country. This template will only be used if the  field "Fix CustomerNo." is blank';
#if not CLEAN22
                    Visible = NewTemplatesEnabled;
#endif
                }
                field(FixCustomerNo; Rec."Default Customer No.")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the default customer for this country when not creating a customer for each webshop user.';
                }
            }

            part(TaxArea; "Shpfy Tax Areas")
            {
                ApplicationArea = All;
                Caption = 'Tax Areas';
                SubPageLink = "Country/Region Code" = field("Country/Region Code");
            }
        }
    }
    actions
    {
        area(Processing)
        {
            action(Import)
            {
                ApplicationArea = All;
                Caption = 'Import countries and counties';
                Image = Import;
                Promoted = true;
                PromotedCategory = Process;
                PromotedIsBig = true;
                PromotedOnly = true;
                ToolTip = 'Import the countries from Shopify where products are sold together with the taxes defined for the relevant company.';

                trigger OnAction()
                var
                    Shop: Record "Shpfy Shop";
                    Sync: Codeunit "Shpfy Background Syncs";
                begin
                    Shop.Get(Rec.GetFilter("Shop Code"));
                    Shop.SetRecFilter();
                    Sync.CountrySync(Shop);
                end;
            }
        }
    }
#if not CLEAN22
    var
        NewTemplatesEnabled: Boolean;
#endif

    trigger OnOpenPage()
#if not CLEAN22
    var
        ShpfyTemplates: Codeunit "Shpfy Templates";
#endif
    begin
#if not CLEAN22
        NewTemplatesEnabled := ShpfyTemplates.NewTemplatesEnabled();
#endif
    end;
}