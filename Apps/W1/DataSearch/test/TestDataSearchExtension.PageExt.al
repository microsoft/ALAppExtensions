pageextension 139507 "Test Data Search Extension" extends "Data Search"
{

    actions
    {
        addlast(Reporting)
        {
            action(TestSearchForSalesOrders)
            {
                ApplicationArea = All;
                Visible = false;
                ToolTip = 'test';
                Image = AboutNav;

                trigger OnAction()
                begin
                    TestSearchSalesOrders();
                end;
            }
            action(TestClearResults)
            {
                ApplicationArea = All;
                Visible = false;
                ToolTip = 'test';
                Image = AboutNav;

                trigger OnAction()
                begin
                    CurrPage.LinesPart.Page.ClearResults();
                end;
            }
        }
    }

    local procedure TestSearchSalesOrders()
    var
        DataSearchSetupTable: Record "Data Search Setup (Table)";
        DataSearchInTable: Codeunit "Data Search In Table";
        SalesDocumentType: Enum "Sales Document Type";
        Results: Dictionary of [Text, Text];
    begin
        SetSearchString('hello world');
        DataSearchSetupTable.Get(DataSearchSetupTable.GetRoleCenterID(), Database::"Sales Line", SalesDocumentType::Order.AsInteger());
        DataSearchInTable.FindInTable(Database::"Sales Line", SalesDocumentType::Order.AsInteger(), 'hello world', Results);
        AddResults(DataSearchSetupTable."Table/Type ID", Results);
        Clear(Results);
        DataSearchSetupTable.Get(DataSearchSetupTable.GetRoleCenterID(), Database::"Sales Line Archive", SalesDocumentType::Order.AsInteger());
        DataSearchInTable.FindInTable(Database::"Sales Line Archive", SalesDocumentType::Order.AsInteger(), 'hello world', Results);
        AddResults(DataSearchSetupTable."Table/Type ID", Results);
    end;

}