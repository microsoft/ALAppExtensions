// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------

/// <summary>
/// Gets the email message IDs based on the filters on the email related records.
/// </summary>
query 8890 "Email Related Record"
{
    Access = Internal;
    QueryType = Normal;
    Permissions = tabledata "Email Related Record" = r;

    elements
    {
        dataitem(RelatedRecord; "Email Related Record")
        {
            /// <summary>
            /// Email message id
            /// </summary>
            column(Email_Message_Id; "Email Message Id") { }

            /// <summary>
            /// Table id for related record
            /// </summary>
            filter(Table_Id; "Table Id") { }

            /// <summary>
            /// System id for related record
            /// </summary>
            filter(System_Id; "System Id") { }
        }
    }

    var
        InvalidNumberOdIDsPerFilterErr: Label 'Expected to have more than 0 email message ID per filter.';

    procedure GetEmailMessageIdFilters(): List of [Text]
    begin
        // Specifying 100 here as a reasonable middle ground between excessive "chattiness" and excessive number of parameters for the SQL query
        exit(GetEmailMessageIdFilters(100));
    end;

    procedure GetEmailMessageIdFilters(MaxIdsPerFilter: Integer): List of [Text]
    var
        // using a dictionary here as there is no "Set" AL type 
        EmailMessageIds: Dictionary of [Guid, Boolean];
        EmailMessageIdsFilters: List of [Text];
        FilterTextBuilder: TextBuilder;
        CurrentIdsPerFilter: Integer;
        MessageId: Guid;
    begin
        if (MaxIdsPerFilter < 1) then
            Error(InvalidNumberOdIDsPerFilterErr);

        if not Open() then
            exit;

        while Read() do
            EmailMessageIds.Set(Email_Message_Id, true);

        CurrentIdsPerFilter := 0;
        foreach MessageId in EmailMessageIds.Keys() do
            if CurrentIdsPerFilter < MaxIdsPerFilter - 1 then begin
                AddToFilter(FilterTextBuilder, MessageId);
                CurrentIdsPerFilter += 1;
            end else begin
                AddToFilter(FilterTextBuilder, MessageId);
                EmailMessageIdsFilters.Add(FilterTextBuilder.ToText());
                Clear(FilterTextBuilder);
                CurrentIdsPerFilter := 0;
            end;

        // the last batch that didn't reach MaxIdsPerFilter
        if FilterTextBuilder.Length() > 0 then
            EmailMessageIdsFilters.Add(FilterTextBuilder.ToText());

        exit(EmailMessageIdsFilters);
    end;

    local procedure AddToFilter(var FilterTextBuilder: TextBuilder; MessageId: Guid)
    begin
        if FilterTextBuilder.Length() = 0 then
            FilterTextBuilder.Append(MessageId)
        else begin
            FilterTextBuilder.Append('|');
            FilterTextBuilder.Append(MessageId);
        end;
    end;
}