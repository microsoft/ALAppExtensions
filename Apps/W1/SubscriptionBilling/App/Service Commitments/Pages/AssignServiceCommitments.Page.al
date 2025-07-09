namespace Microsoft.SubscriptionBilling;

using Microsoft.Sales.Document;
using Microsoft.Inventory.Item;

page 8065 "Assign Service Commitments"
{
    Caption = 'Assign Subscription Lines';
    PageType = ListPlus;
    SourceTable = "Subscription Package";
    InsertAllowed = false;
    DeleteAllowed = false;
    ModifyAllowed = false;
    ShowFilter = false;
    UsageCategory = None;
    ApplicationArea = All;

    layout
    {
        area(content)
        {
            group(General)
            {
                Caption = 'General';
                Visible = not OpenedFromSalesLine;
                field(FieldServiceAndCalculationStartDate; ServiceAndCalculationStartDate)
                {
                    Caption = 'Subscription Line and Calculation Start Date';
                    ToolTip = 'Specifies the date from which the Subscription Line(s) are valid and should be calculated. The date is taken over when Subscription Lines are created as Subscription Line Start Date and Next Calculation Date.';
                }
                field(ItemNo; ServiceObject."Source No.")
                {
                    Editable = false;
                    Caption = 'Item No.';
                    ToolTip = 'Specifies the Item No. of the Subscription.';
                }
            }
            repeater(RepeaterControl)
            {
                field("Code"; Rec.Code)
                {
                    ShowMandatory = true;
                    ToolTip = 'Specifies a code to identify this Subscription Package.';
                    Editable = false;

                    trigger OnValidate()
                    begin
                        CurrPage.Update();
                    end;
                }
                field(Description; Rec.Description)
                {
                    ToolTip = 'Specifies a description of the Subscription Package.';
                    Editable = false;

                }
            }
            part(PackageLines; "Service Comm. Package Lines")
            {
                Editable = false;
                SubPageLink = "Subscription Package Code" = field(Code);
                UpdatePropagation = Both;
            }
        }
    }

    trigger OnAfterGetCurrRecord()
    begin
        if Rec.IsEmpty() then
            exit;
        CurrPage.Update(false);
    end;

    trigger OnQueryClosePage(CloseAction: Action): Boolean
    begin
        if not OpenedFromSalesLine then
            exit;

        if CloseAction = Action::LookupOK then
            ErrorIfInvoicingItemNoIsMissingForSalesWithServiceCommitmentItem();
    end;

    var
        ServiceObject: Record "Subscription Header";
        SalesLine: Record "Sales Line";
        OpenedFromSalesLine: Boolean;
        ServiceAndCalculationStartDate: Date;

    internal procedure SetServiceObject(NewServiceObject: Record "Subscription Header")
    begin
        ServiceObject := NewServiceObject;
    end;

    procedure SetSalesLine(NewSalesLine: Record "Sales Line")
    begin
        SalesLine := NewSalesLine;
        OpenedFromSalesLine := true;
    end;

    procedure GetSelectionFilter(var ServiceCommitmentPackage: Record "Subscription Package")
    begin
        CurrPage.SetSelectionFilter(ServiceCommitmentPackage);
    end;

    internal procedure GetServiceAndCalculationStartDate(): Date
    begin
        exit(ServiceAndCalculationStartDate);
    end;

    local procedure ErrorIfInvoicingItemNoIsMissingForSalesWithServiceCommitmentItem(): Boolean
    var
        Item: Record Item;
        ServiceCommitmentPackage: Record "Subscription Package";
        EmptyInvoicingItemNoInPackageLineErr: Label 'The %1 %2 can not be used with Item %3, because at least one of the Service Commitment Package lines is missing an "Invoicing Item No."', Comment = '%1=Table Caption, %2=Code, %3=Item No.';
    begin
        if SalesLine.Type <> SalesLine.Type::Item then
            exit;

        if not Item.Get(SalesLine."No.") then
            exit;

        if Item."Subscription Option" <> Enum::"Item Service Commitment Type"::"Sales with Service Commitment" then
            exit;

        CurrPage.SetSelectionFilter(ServiceCommitmentPackage);
        if ServiceCommitmentPackage.FindSet() then
            repeat
                if ServiceCommitmentPackage.PackageLineInvoicedViaContractWithoutInvoicingItemExist() then
                    Error(EmptyInvoicingItemNoInPackageLineErr, ServiceCommitmentPackage.TableCaption, ServiceCommitmentPackage.Code, Item."No.");
            until ServiceCommitmentPackage.Next() = 0;
        exit(true);
    end;
}