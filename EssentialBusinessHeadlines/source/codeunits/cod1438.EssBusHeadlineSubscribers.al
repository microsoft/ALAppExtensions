// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------

codeunit 1438 "Ess. Bus. Headline Subscribers"
{

    var
        EssentialBusinessHeadline: Record "Ess. Business Headline Per Usr";
        EssentialBusHeadlineMgt: Codeunit "Essential Bus. Headline Mgt.";

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Headline Management", 'OnInvalidateHeadlines', '', true, true)]
    procedure OnInvalidateHeadlines()
    begin
        if not EssentialBusinessHeadline.WritePermission() then
            exit;

        EssentialBusinessHeadline.SetRange("User Id", UserSecurityId());
        EssentialBusinessHeadline.DeleteAll();
    end;

    local procedure TransferHeadlineToPage(HeadlineName: Option; var HeadlineText: Text[250]; var HeadlineVisible: Boolean)
    var
        EssentialBusinessHeadline: Record "Ess. Business Headline Per Usr";
    begin
        if EssentialBusinessHeadline.Get(HeadlineName, UserSecurityId()) then begin
            HeadlineVisible := EssentialBusinessHeadline."Headline Visible";
            HeadlineText := EssentialBusinessHeadline."Headline Text";
        end else
            HeadlineVisible := false;
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Headline RC Business Manager", 'OnComputeHeadlines', '', true, true)]
    procedure OnComputeHeadlinesBusinessManager()
    begin
        if not EssentialBusinessHeadline.WritePermission() then
            exit;

        EssentialBusHeadlineMgt.HandleLargestOrderHeadline();
        EssentialBusHeadlineMgt.HandleLargestSaleHeadline();
        EssentialBusHeadlineMgt.HandleMostPopularItemHeadline();
        EssentialBusHeadlineMgt.HandleBusiestResourceHeadline();
        EssentialBusHeadlineMgt.HandleSalesIncreaseHeadline();
        EssentialBusHeadlineMgt.HandleTopCustomer();
    end;

    [EventSubscriber(ObjectType::Page, Page::"Headline RC Business Manager", 'OnIsAnyExtensionHeadlineVisible', '', true, true)]
    procedure OnIsAnyExtensionHeadlineVisible(var ExtensionHeadlinesVisible: Boolean)
    var
        EssentialBusinessHeadline: Record "Ess. Business Headline Per Usr";
        AtLeastOneHeadlineVisible: Boolean;
    begin
        EssentialBusinessHeadline.SetRange("Headline Visible", true);
        EssentialBusinessHeadline.SetRange("User Id", UserSecurityId());
        EssentialBusinessHeadline.SetFilter("Headline Name", '%1|%2|%3|%4|%5',
            EssentialBusinessHeadline."Headline Name"::LargestOrder,
            EssentialBusinessHeadline."Headline Name"::LargestSale,
            EssentialBusinessHeadline."Headline Name"::BusiestResource,
            EssentialBusinessHeadline."Headline Name"::MostPopularItem,
            EssentialBusinessHeadline."Headline Name"::SalesIncrease,
            EssentialBusinessHeadline."Headline Name"::TopCustomer);

        AtLeastOneHeadlineVisible := not EssentialBusinessHeadline.IsEmpty();
        // only modify the var if this extension is making some headlines visible, setting to false could overrride some other extensions setting the value to true
        if AtLeastOneHeadlineVisible then
            ExtensionHeadlinesVisible := true;
    end;

    [EventSubscriber(ObjectType::Page, Page::"Headline RC Business Manager", 'OnSetVisibility', '', true, true)]
    procedure OnSetVisibilityBusinessManager(var MostPopularItemVisible: Boolean; var MostPopularItemText: Text[250];
                                    var LargestOrderVisible: Boolean; var LargestOrderText: Text[250];
                                    var LargestSaleVisible: Boolean; var LargestSaleText: Text[250];
                                    var SalesIncreaseVisible: Boolean; var SalesIncreaseText: Text[250];
                                    var BusiestResourceVisible: Boolean; var BusiestResourceText: Text[250];
                                    var TopCustomerVisible: Boolean; var TopCustomerText: Text[250])
    var
        EssentialBusinessHeadline: Record "Ess. Business Headline Per Usr";
    begin
        TransferHeadlineToPage(EssentialBusinessHeadline."Headline Name"::MostPopularItem, MostPopularItemText, MostPopularItemVisible);
        TransferHeadlineToPage(EssentialBusinessHeadline."Headline Name"::LargestOrder, LargestOrderText, LargestOrderVisible);
        TransferHeadlineToPage(EssentialBusinessHeadline."Headline Name"::LargestSale, LargestSaleText, LargestSaleVisible);
        TransferHeadlineToPage(EssentialBusinessHeadline."Headline Name"::SalesIncrease, SalesIncreaseText, SalesIncreaseVisible);
        TransferHeadlineToPage(EssentialBusinessHeadline."Headline Name"::BusiestResource, BusiestResourceText, BusiestResourceVisible);
        TransferHeadlineToPage(EssentialBusinessHeadline."Headline Name"::TopCustomer, TopCustomerText, TopCustomerVisible);
    end;


    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Headline RC Order Processor", 'OnComputeHeadlines', '', true, true)]
    procedure OnComputeHeadlinesOrderProcessor()
    begin
        if not EssentialBusinessHeadline.WritePermission() then
            exit;

        EssentialBusHeadlineMgt.HandleLargestOrderHeadline();
        EssentialBusHeadlineMgt.HandleLargestSaleHeadline();
    end;

    [EventSubscriber(ObjectType::Page, Page::"Headline RC Order Processor", 'OnIsAnyExtensionHeadlineVisible', '', true, true)]
    procedure OnIsAnyExtensionHeadlineVisibleOrderProcessor(var ExtensionHeadlinesVisible: Boolean)
    var
        EssentialBusinessHeadline: Record "Ess. Business Headline Per Usr";
        AtLeastOneHeadlineVisible: Boolean;
    begin
        EssentialBusinessHeadline.SetRange("Headline Visible", true);
        EssentialBusinessHeadline.SetRange("User Id", UserSecurityId());
        EssentialBusinessHeadline.SetFilter("Headline Name", '%1|%2',
            EssentialBusinessHeadline."Headline Name"::LargestOrder,
            EssentialBusinessHeadline."Headline Name"::LargestSale);

        AtLeastOneHeadlineVisible := not EssentialBusinessHeadline.IsEmpty();
        // only modify the var if this extension is making some headlines visible, setting to false could overrride some other extensions setting the value to true
        if AtLeastOneHeadlineVisible then
            ExtensionHeadlinesVisible := true;
    end;

    [EventSubscriber(ObjectType::Page, Page::"Headline RC Order Processor", 'OnSetVisibility', '', true, true)]
    procedure OnSetVisibilityOrderProcessor(var LargestOrderVisible: Boolean; var LargestOrderText: Text[250]; var LargestSaleVisible: Boolean; var LargestSaleText: Text[250])
    var
        EssentialBusinessHeadline: Record "Ess. Business Headline Per Usr";
    begin
        TransferHeadlineToPage(EssentialBusinessHeadline."Headline Name"::LargestOrder, LargestOrderText, LargestOrderVisible);
        TransferHeadlineToPage(EssentialBusinessHeadline."Headline Name"::LargestSale, LargestSaleText, LargestSaleVisible);
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Headline RC Accountant", 'OnComputeHeadlines', '', true, true)]
    procedure OnComputeHeadlinesAccountant()
    begin
        if not EssentialBusinessHeadline.WritePermission() then
            exit;

        EssentialBusHeadlineMgt.HandleLargestOrderHeadline();
        EssentialBusHeadlineMgt.HandleLargestSaleHeadline();
        EssentialBusHeadlineMgt.HandleSalesIncreaseHeadline();
    end;

    [EventSubscriber(ObjectType::Page, Page::"Headline RC Accountant", 'OnIsAnyExtensionHeadlineVisible', '', true, true)]
    procedure OnIsAnyExtensionHeadlineVisibleAccountant(var ExtensionHeadlinesVisible: Boolean)
    var
        EssentialBusinessHeadline: Record "Ess. Business Headline Per Usr";
        AtLeastOneHeadlineVisible: Boolean;
    begin
        EssentialBusinessHeadline.SetRange("Headline Visible", true);
        EssentialBusinessHeadline.SetRange("User Id", UserSecurityId());
        EssentialBusinessHeadline.SetFilter("Headline Name", '%1|%2|%3',
            EssentialBusinessHeadline."Headline Name"::LargestOrder,
            EssentialBusinessHeadline."Headline Name"::LargestSale,
            EssentialBusinessHeadline."Headline Name"::SalesIncrease);

        AtLeastOneHeadlineVisible := not EssentialBusinessHeadline.IsEmpty();
        // only modify the var if this extension is making some headlines visible, setting to false could overrride some other extensions setting the value to true
        if AtLeastOneHeadlineVisible then
            ExtensionHeadlinesVisible := true;
    end;

    [EventSubscriber(ObjectType::Page, Page::"Headline RC Accountant", 'OnSetVisibility', '', true, true)]
    procedure OnSetVisibilityAccountant(var LargestOrderVisible: Boolean; var LargestOrderText: Text[250];
                                        var LargestSaleVisible: Boolean; var LargestSaleText: Text[250];
                                        var SalesIncreaseVisible: Boolean; var SalesIncreaseText: Text[250])
    var
        EssentialBusinessHeadline: Record "Ess. Business Headline Per Usr";
    begin
        TransferHeadlineToPage(EssentialBusinessHeadline."Headline Name"::LargestOrder, LargestOrderText, LargestOrderVisible);
        TransferHeadlineToPage(EssentialBusinessHeadline."Headline Name"::LargestSale, LargestSaleText, LargestSaleVisible);
        TransferHeadlineToPage(EssentialBusinessHeadline."Headline Name"::SalesIncrease, SalesIncreaseText, SalesIncreaseVisible);
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Headline RC Relationship Mgt.", 'OnComputeHeadlines', '', true, true)]
    procedure OnComputeHeadlinesRelationshipMgt()
    var
    begin
        if not EssentialBusinessHeadline.WritePermission() then
            exit;

        EssentialBusHeadlineMgt.HandleTopCustomer();
    end;

    [EventSubscriber(ObjectType::Page, Page::"Headline RC Relationship Mgt.", 'OnIsAnyExtensionHeadlineVisible', '', true, true)]
    procedure OnIsAnyExtensionHeadlineVisibleRelationshipMgt(var ExtensionHeadlinesVisible: Boolean)
    var
        EssentialBusinessHeadline: Record "Ess. Business Headline Per Usr";
        AtLeastOneHeadlineVisible: Boolean;
    begin
        EssentialBusinessHeadline.SetRange("Headline Visible", true);
        EssentialBusinessHeadline.SetRange("User Id", UserSecurityId());
        EssentialBusinessHeadline.SetFilter("Headline Name", '%1',
            EssentialBusinessHeadline."Headline Name"::TopCustomer);

        AtLeastOneHeadlineVisible := not EssentialBusinessHeadline.IsEmpty();
        // only modify the var if this extension is making some headlines visible, setting to false could overrride some other extensions setting the value to true
        if AtLeastOneHeadlineVisible then
            ExtensionHeadlinesVisible := true;
    end;

    [EventSubscriber(ObjectType::Page, Page::"Headline RC Relationship Mgt.", 'OnSetVisibility', '', true, true)]
    procedure OnSetVisibilityRelMgt(var TopCustomerVisible: Boolean; var TopCustomerText: Text[250])
    var
        EssentialBusinessHeadline: Record "Ess. Business Headline Per Usr";
    begin
        TransferHeadlineToPage(EssentialBusinessHeadline."Headline Name"::TopCustomer, TopCustomerText, TopCustomerVisible);
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Headline RC Administrator", 'OnComputeHeadlines', '', true, true)]
    procedure OnComputeHeadlinesAdministrator()
    begin
        //TODO
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Headline RC Team Member", 'OnComputeHeadlines', '', true, true)]
    procedure OnComputeHeadlinesTeamMember()
    begin
        //TODO
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Headline RC Project Manager", 'OnComputeHeadlines', '', true, true)]
    procedure OnComputeHeadlinesProjectManager()
    begin
        //TODO
    end;
}