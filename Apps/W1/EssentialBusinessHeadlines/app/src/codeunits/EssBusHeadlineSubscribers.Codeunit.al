// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
codeunit 1438 "Ess. Bus. Headline Subscribers"
{

    var
        EssentialBusHeadlineMgt: Codeunit "Essential Bus. Headline Mgt.";

    local procedure CanRunSubscribers(): Boolean
    begin
        exit(Session.GetExecutionContext() = Session.GetExecutionContext() ::Normal);
    end;

#if not CLEAN19
#pragma warning disable AS0072, AS0022, AS0018
    [Obsolete('My Settings has been obsoleted', '19.0')]
    [EventSubscriber(ObjectType::Page, Page::"My Settings", 'OnBeforeLanguageChange', '', true, true)]
    procedure OnBeforeUpdateLanguage(OldLanguageId: Integer; NewLanguageId: Integer);
    begin
        InvalidateHeadlines();
    end;

    [Obsolete('My Settings has been obsoleted', '19.0')]
    [EventSubscriber(ObjectType::Page, Page::"My Settings", 'OnBeforeWorkdateChange', '', true, true)]
    procedure OnBeforeUpdateWorkdate(OldWorkdate: Date; NewWorkdate: Date);
    begin
        InvalidateHeadlines();
    end;
#pragma warning restore
#else
    [EventSubscriber(ObjectType::Codeunit, Codeunit::"User Settings", 'OnUpdateUserSettings', '', true, true)]
    local procedure OnBeforeUpdateUserSettings(NewSettings: Record "User Settings"; OldSettings: Record "User Settings");
    begin
        if (OldSettings."Language ID" <> NewSettings."Language ID") or
           (OldSettings."Work Date" <> NewSettings."Work Date")
        then
            InvalidateHeadlines();
    end;
#endif
    local procedure InvalidateHeadlines()
    var
        EssentialBusinessHeadline: Record "Ess. Business Headline Per Usr";
    begin
        if not EssentialBusinessHeadline.WritePermission() then
            exit;
        if not CanRunSubscribers() then
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

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"RC Headlines Executor", 'OnComputeHeadlines', '', true, true)]
    procedure OnComputeRoleCenterHeadlines(RoleCenterPageID: Integer)
    var
        EssentialBusinessHeadline: Record "Ess. Business Headline Per Usr";
    begin
        if not EssentialBusinessHeadline.WritePermission() then
            exit;
        if not CanRunSubscribers() then
            exit;

        case RoleCenterPageID of
            Page::"Headline RC Business Manager":
                begin
                    EssentialBusHeadlineMgt.HandleLargestOrderHeadline();
                    EssentialBusHeadlineMgt.HandleLargestSaleHeadline();
                    EssentialBusHeadlineMgt.HandleMostPopularItemHeadline();
                    EssentialBusHeadlineMgt.HandleBusiestResourceHeadline();
                    EssentialBusHeadlineMgt.HandleSalesIncreaseHeadline();
                    EssentialBusHeadlineMgt.HandleTopCustomer();
                    EssentialBusHeadlineMgt.HandleOpenVATReturn();
                    EssentialBusHeadlineMgt.HandleOverdueVATReturn();
                    EssentialBusHeadlineMgt.HandleRecentlyOverdueInvoices();
                end;
            Page::"Headline RC Order Processor":
                begin
                    EssentialBusHeadlineMgt.HandleLargestOrderHeadline();
                    EssentialBusHeadlineMgt.HandleLargestSaleHeadline();
                end;
            Page::"Headline RC Accountant":
                begin
                    EssentialBusHeadlineMgt.HandleLargestOrderHeadline();
                    EssentialBusHeadlineMgt.HandleLargestSaleHeadline();
                    EssentialBusHeadlineMgt.HandleSalesIncreaseHeadline();
                end;
            Page::"Headline RC Relationship Mgt.":
                EssentialBusHeadlineMgt.HandleTopCustomer();
        end;

    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"RC Headlines Page Common", 'OnIsAnyExtensionHeadlineVisible', '', true, true)]
    procedure OnIsAnyExtensionHeadlineVisible(var ExtensionHeadlinesVisible: Boolean; RoleCenterPageID: Integer)
    var
        EssentialBusinessHeadline: Record "Ess. Business Headline Per Usr";
        AtLeastOneHeadlineVisible: Boolean;
    begin
        if not CanRunSubscribers() then
            exit;
        if not EssentialBusinessHeadline.ReadPermission() then
            exit;

        EssentialBusinessHeadline.SetRange("Headline Visible", true);
        EssentialBusinessHeadline.SetRange("User Id", UserSecurityId());

        case RoleCenterPageID of
            Page::"Headline RC Business Manager":
                EssentialBusinessHeadline.SetFilter("Headline Name", '%1|%2|%3|%4|%5|%6|%7|%8|%9',
                    EssentialBusinessHeadline."Headline Name"::LargestOrder,
                    EssentialBusinessHeadline."Headline Name"::LargestSale,
                    EssentialBusinessHeadline."Headline Name"::BusiestResource,
                    EssentialBusinessHeadline."Headline Name"::MostPopularItem,
                    EssentialBusinessHeadline."Headline Name"::SalesIncrease,
                    EssentialBusinessHeadline."Headline Name"::TopCustomer,
                    EssentialBusinessHeadline."Headline Name"::OpenVATReturn,
                    EssentialBusinessHeadline."Headline Name"::OverdueVATReturn,
                    EssentialBusinessHeadline."Headline Name"::RecentlyOverdueInvoices);
            Page::"Headline RC Order Processor":
                EssentialBusinessHeadline.SetFilter("Headline Name", '%1|%2',
                    EssentialBusinessHeadline."Headline Name"::LargestOrder,
                    EssentialBusinessHeadline."Headline Name"::LargestSale);
            Page::"Headline RC Accountant":
                EssentialBusinessHeadline.SetFilter("Headline Name", '%1|%2|%3',
                    EssentialBusinessHeadline."Headline Name"::LargestOrder,
                    EssentialBusinessHeadline."Headline Name"::LargestSale,
                    EssentialBusinessHeadline."Headline Name"::SalesIncrease);
            Page::"Headline RC Relationship Mgt.":
                EssentialBusinessHeadline.SetFilter("Headline Name", '%1',
                    EssentialBusinessHeadline."Headline Name"::TopCustomer);
        end;

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
                                             var TopCustomerVisible: Boolean; var TopCustomerText: Text[250];
                                             var RecentlyOverdueInvoicesVisible: Boolean; var RecentlyOverdueInvoicesText: Text[250])
    var
        EssentialBusinessHeadline: Record "Ess. Business Headline Per Usr";
    begin
        if not CanRunSubscribers() then
            exit;
        if not EssentialBusinessHeadline.ReadPermission() then
            exit;

        TransferHeadlineToPage(EssentialBusinessHeadline."Headline Name"::MostPopularItem, MostPopularItemText, MostPopularItemVisible);
        TransferHeadlineToPage(EssentialBusinessHeadline."Headline Name"::LargestOrder, LargestOrderText, LargestOrderVisible);
        TransferHeadlineToPage(EssentialBusinessHeadline."Headline Name"::LargestSale, LargestSaleText, LargestSaleVisible);
        TransferHeadlineToPage(EssentialBusinessHeadline."Headline Name"::SalesIncrease, SalesIncreaseText, SalesIncreaseVisible);
        TransferHeadlineToPage(EssentialBusinessHeadline."Headline Name"::BusiestResource, BusiestResourceText, BusiestResourceVisible);
        TransferHeadlineToPage(EssentialBusinessHeadline."Headline Name"::TopCustomer, TopCustomerText, TopCustomerVisible);
        TransferHeadlineToPage(EssentialBusinessHeadline."Headline Name"::RecentlyOverdueInvoices, RecentlyOverdueInvoicesText, RecentlyOverdueInvoicesVisible);
    end;

    [EventSubscriber(ObjectType::Page, Page::"Headline RC Business Manager", 'OnSetVisibilityOpenVATReturn', '', true, true)]
    procedure OnSetVisibilityBusinessManagerOpenVATReturn(var OpenVATReturnVisible: Boolean; var OpenVATReturnText: Text[250])
    var
        EssentialBusinessHeadline: Record "Ess. Business Headline Per Usr";
    begin
        if not CanRunSubscribers() then
            exit;
        if not EssentialBusinessHeadline.ReadPermission() then
            exit;

        TransferHeadlineToPage(EssentialBusinessHeadline."Headline Name"::OpenVATReturn, OpenVATReturnText, OpenVATReturnVisible);
    end;

    [EventSubscriber(ObjectType::Page, Page::"Headline RC Business Manager", 'OnSetVisibilityOverdueVATReturn', '', true, true)]
    procedure OnSetVisibilityBusinessManagerOverdueVATReturn(var OverdueVATReturnVisible: Boolean; var OverdueVATReturnText: Text[250])
    var
        EssentialBusinessHeadline: Record "Ess. Business Headline Per Usr";
    begin
        if not CanRunSubscribers() then
            exit;
        if not EssentialBusinessHeadline.ReadPermission() then
            exit;

        TransferHeadlineToPage(EssentialBusinessHeadline."Headline Name"::OverdueVATReturn, OverdueVATReturnText, OverdueVATReturnVisible);
    end;

    [EventSubscriber(ObjectType::Page, Page::"Headline RC Order Processor", 'OnSetVisibility', '', true, true)]
    procedure OnSetVisibilityOrderProcessor(var LargestOrderVisible: Boolean; var LargestOrderText: Text[250]; var LargestSaleVisible: Boolean; var LargestSaleText: Text[250])
    var
        EssentialBusinessHeadline: Record "Ess. Business Headline Per Usr";
    begin
        if not CanRunSubscribers() then
            exit;
        if not EssentialBusinessHeadline.ReadPermission() then
            exit;

        TransferHeadlineToPage(EssentialBusinessHeadline."Headline Name"::LargestOrder, LargestOrderText, LargestOrderVisible);
        TransferHeadlineToPage(EssentialBusinessHeadline."Headline Name"::LargestSale, LargestSaleText, LargestSaleVisible);
    end;

    [EventSubscriber(ObjectType::Page, Page::"Headline RC Accountant", 'OnSetVisibility', '', true, true)]
    procedure OnSetVisibilityAccountant(var LargestOrderVisible: Boolean; var LargestOrderText: Text[250];
                                        var LargestSaleVisible: Boolean; var LargestSaleText: Text[250];
                                        var SalesIncreaseVisible: Boolean; var SalesIncreaseText: Text[250])
    var
        EssentialBusinessHeadline: Record "Ess. Business Headline Per Usr";
    begin
        if not CanRunSubscribers() then
            exit;
        if not EssentialBusinessHeadline.ReadPermission() then
            exit;

        TransferHeadlineToPage(EssentialBusinessHeadline."Headline Name"::LargestOrder, LargestOrderText, LargestOrderVisible);
        TransferHeadlineToPage(EssentialBusinessHeadline."Headline Name"::LargestSale, LargestSaleText, LargestSaleVisible);
        TransferHeadlineToPage(EssentialBusinessHeadline."Headline Name"::SalesIncrease, SalesIncreaseText, SalesIncreaseVisible);
    end;

    [EventSubscriber(ObjectType::Page, Page::"Headline RC Relationship Mgt.", 'OnSetVisibility', '', true, true)]
    procedure OnSetVisibilityRelMgt(var TopCustomerVisible: Boolean; var TopCustomerText: Text[250])
    var
        EssentialBusinessHeadline: Record "Ess. Business Headline Per Usr";
    begin
        if not CanRunSubscribers() then
            exit;
        if not EssentialBusinessHeadline.ReadPermission() then
            exit;

        TransferHeadlineToPage(EssentialBusinessHeadline."Headline Name"::TopCustomer, TopCustomerText, TopCustomerVisible);
    end;

}
