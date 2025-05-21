namespace Microsoft.Integration.Shopify;

/// <summary>
/// Codeunit Shpfy Staff Member API (ID 30105).
/// </summary>
codeunit 30105 "Shpfy Staff Member API"
{
    Access = Internal;

    /// <summary>
    /// Retrieves staff members from Shopify and updates the local database.
    /// </summary>
    /// <param name="ShopCode">The code of the Shopify shop.</param>
    internal procedure GetStaffMembers(ShopCode: Code[20])
    var
        ShpfyShop: Record "Shpfy Shop";
        TempShpfyStaffMember: Record "Shpfy Staff Member" temporary;
        CommunicationMgt: Codeunit "Shpfy Communication Mgt.";
        JsonHelper: Codeunit "Shpfy Json Helper";
        GraphQLType: Enum "Shpfy GraphQL Type";
        JResponse: JsonToken;
        Parameters: Dictionary of [Text, Text];
        Cursor: Text;
    begin
        ShpfyShop.Get(ShopCode);
        if not ShpfyShop."B2B Enabled" then
            exit;

        CommunicationMgt.SetShop(ShpfyShop.Code);

        GraphQLType := GraphQLType::GetStaffMembers;
        repeat
            JResponse := CommunicationMgt.ExecuteGraphQL(GraphQLType, Parameters);
            if JResponse.IsObject() then
                if this.ExtractStaffMembers(JResponse.AsObject(), Cursor, ShpfyShop.Code, TempShpfyStaffMember) then begin
                    if Parameters.ContainsKey('After') then
                        Parameters.Set('After', Cursor)
                    else
                        Parameters.Add('After', Cursor);
                    GraphQLType := GraphQLType::GetNextStaffMembers;
                end else
                    break;
        until not JsonHelper.GetValueAsBoolean(JResponse, 'data.staffMembers.pageInfo.hasNextPage');
        this.CreateUpdateStaffMembers(ShopCode, TempShpfyStaffMember);
    end;

    /// <summary>
    /// Extracts staff members from the JSON response and populates the temporary staff member record.
    /// </summary>
    /// <param name="JResponse">The JSON response object.</param>
    /// <param name="Cursor">The cursor for pagination.</param>
    /// <param name="ShopCode">The code of the Shopify shop.</param>
    /// <param name="TempShpfyStaffMember">The temporary staff member record to populate.</param>
    /// <returns>True if extraction was successful; otherwise, false.</returns>
    local procedure ExtractStaffMembers(JResponse: JsonObject; var Cursor: Text; ShopCode: Code[20]; var TempShpfyStaffMember: Record "Shpfy Staff Member" temporary): Boolean
    var
        CommunicationMgt: Codeunit "Shpfy Communication Mgt.";
        JsonHelper: Codeunit "Shpfy Json Helper";
        JStaffMembers: JsonArray;
        JStaffMemberInfo: JsonObject;
        JStaffMember: JsonToken;
    begin
        if JsonHelper.GetValueAsBoolean(JResponse, 'data.staffMembers.pageInfo.hasNextPage') then
            Cursor := JsonHelper.GetValueAsText(JResponse, 'data.staffMembers.pageInfo.endCursor');
        JsonHelper.GetJsonArray(JResponse, JStaffMembers, 'data.staffMembers.edges');
        foreach JStaffMember in JStaffMembers do
            if JsonHelper.GetJsonObject(JStaffMember.AsObject(), JStaffMemberInfo, 'node') then begin
                Clear(TempShpfyStaffMember);
                TempShpfyStaffMember.Init();
                TempShpfyStaffMember."Shop Code" := ShopCode;
                TempShpfyStaffMember.Id := CommunicationMgt.GetIdOfGId(JsonHelper.GetValueAsText(JStaffMemberInfo, 'id'));
                if Evaluate(TempShpfyStaffMember."Account Type", CommunicationMgt.ConvertToCleanOptionValue(JsonHelper.GetValueAsText(JStaffMemberInfo, 'accountType'))) then;
                TempShpfyStaffMember.Active := JsonHelper.GetValueAsBoolean(JStaffMemberInfo, 'active');
                TempShpfyStaffMember.Email := CopyStr(JsonHelper.GetValueAsText(JStaffMemberInfo, 'email'), 1, MaxStrLen(TempShpfyStaffMember.Email));
                TempShpfyStaffMember.Exists := JsonHelper.GetValueAsBoolean(JStaffMemberInfo, 'exists');
                TempShpfyStaffMember."First Name" := CopyStr(JsonHelper.GetValueAsText(JStaffMemberInfo, 'firstName'), 1, MaxStrLen(TempShpfyStaffMember."First Name"));
                TempShpfyStaffMember.Initials := CopyStr(JsonHelper.GetArrayAsText(JStaffMemberInfo, 'initials'), 1, MaxStrLen(TempShpfyStaffMember.Initials));
                TempShpfyStaffMember."Shop Owner" := JsonHelper.GetValueAsBoolean(JStaffMemberInfo, 'isShopOwner');
                TempShpfyStaffMember."Last Name" := CopyStr(JsonHelper.GetValueAsText(JStaffMemberInfo, 'lastName'), 1, MaxStrLen(TempShpfyStaffMember."Last Name"));
                TempShpfyStaffMember.Name := CopyStr(JsonHelper.GetValueAsText(JStaffMemberInfo, 'name'), 1, MaxStrLen(TempShpfyStaffMember.Name));
                TempShpfyStaffMember."Locale" := CopyStr(JsonHelper.GetValueAsText(JStaffMemberInfo, 'locale'), 1, MaxStrLen(TempShpfyStaffMember."Locale"));
                TempShpfyStaffMember.Phone := CopyStr(JsonHelper.GetValueAsText(JStaffMemberInfo, 'phone'), 1, MaxStrLen(TempShpfyStaffMember.Phone));
                TempShpfyStaffMember.Insert();
            end;
        exit(true);
    end;

    /// <summary>
    /// Creates or updates staff members in the database based on the temporary staff member record.
    /// </summary>
    /// <param name="ShopCode">The code of the Shopify shop.</param>
    /// <param name="TempShpfyStaffMember">The temporary staff member record.</param>
    local procedure CreateUpdateStaffMembers(ShopCode: Code[20]; var TempShpfyStaffMember: Record "Shpfy Staff Member" temporary)
    var
        StaffMember: Record "Shpfy Staff Member";
        Modified: Boolean;
        ProcessedStaffMembers: List of [BigInteger];
    begin
        TempShpfyStaffMember.SetRange("Shop Code", ShopCode);
        if TempShpfyStaffMember.FindSet() then
            repeat
                if not ProcessedStaffMembers.Contains(TempShpfyStaffMember.Id) then
                    ProcessedStaffMembers.Add(TempShpfyStaffMember.Id);
                if not StaffMember.Get(ShopCode, TempShpfyStaffMember.Id) then begin
                    StaffMember.Init();
                    StaffMember.TransferFields(TempShpfyStaffMember);
                    StaffMember.Insert();
                end else begin
                    Modified := false;
                    if StaffMember."Account Type" <> TempShpfyStaffMember."Account Type" then begin
                        StaffMember."Account Type" := TempShpfyStaffMember."Account Type";
                        Modified := true;
                    end;
                    if StaffMember.Active <> TempShpfyStaffMember.Active then begin
                        StaffMember.Active := TempShpfyStaffMember.Active;
                        Modified := true;
                    end;
                    if StaffMember.Email <> TempShpfyStaffMember.Email then begin
                        StaffMember.Email := TempShpfyStaffMember.Email;
                        Modified := true;
                    end;
                    if StaffMember.Exists <> TempShpfyStaffMember.Exists then begin
                        StaffMember.Exists := TempShpfyStaffMember.Exists;
                        Modified := true;
                    end;
                    if StaffMember."First Name" <> TempShpfyStaffMember."First Name" then begin
                        StaffMember."First Name" := TempShpfyStaffMember."First Name";
                        Modified := true;
                    end;
                    if StaffMember.Initials <> TempShpfyStaffMember.Initials then begin
                        StaffMember.Initials := TempShpfyStaffMember.Initials;
                        Modified := true;
                    end;
                    if StaffMember."Shop Owner" <> TempShpfyStaffMember."Shop Owner" then begin
                        StaffMember."Shop Owner" := TempShpfyStaffMember."Shop Owner";
                        Modified := true;
                    end;
                    if StaffMember."Last Name" <> TempShpfyStaffMember."Last Name" then begin
                        StaffMember."Last Name" := TempShpfyStaffMember."Last Name";
                        Modified := true;
                    end;
                    if StaffMember."Locale" <> TempShpfyStaffMember."Locale" then begin
                        StaffMember."Locale" := TempShpfyStaffMember."Locale";
                        Modified := true;
                    end;
                    if StaffMember.Name <> TempShpfyStaffMember.Name then begin
                        StaffMember.Name := TempShpfyStaffMember.Name;
                        Modified := true;
                    end;
                    if StaffMember.Phone <> TempShpfyStaffMember.Phone then begin
                        StaffMember.Phone := TempShpfyStaffMember.Phone;
                        Modified := true;
                    end;
                    if Modified then
                        StaffMember.Modify();
                end;
            until TempShpfyStaffMember.Next() = 0;
        StaffMember.Reset();
        StaffMember.SetRange("Shop Code", ShopCode);
        if StaffMember.FindSet() then
            repeat
                if not ProcessedStaffMembers.Contains(StaffMember.Id) then
                    StaffMember.Delete();
            until StaffMember.Next() = 0;
    end;
}