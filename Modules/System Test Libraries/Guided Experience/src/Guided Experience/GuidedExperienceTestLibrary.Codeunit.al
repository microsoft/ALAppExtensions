// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
codeunit 132607 "Guided Experience Test Library"
{
    Permissions = tabledata "Guided Experience Item" = rmd,
                    tabledata "Spotlight Tour Text" = d;

    var
        Any: Codeunit Any;

    /// <summary>
    /// Deletes all the guided experience items and spotlight tour texts in the database.
    /// </summary>
    procedure DeleteAll()
    var
        GuidedExperienceItem: Record "Guided Experience Item";
        SpotlightTourText: Record "Spotlight Tour Text";
    begin
        GuidedExperienceItem.DeleteAll();
        SpotlightTourText.DeleteAll();
    end;

    /// <summary>
    /// Gets the count of entries in the guided experience item table.
    /// </summary>
    /// <returns>The count of entries in the guided experience item table.</returns>
    procedure GetCount(): Integer
    var
        GuidedExperienceItem: Record "Guided Experience Item";
    begin
        exit(GuidedExperienceItem.Count);
    end;

    /// <summary>
    /// Inserts a new assisted setup guided experience item.
    /// </summary>
    /// <param name="ShouldRandomizeFields">If true, the values of the fields that are passed by var will be randomized. If false, it will insert the record with the values that were passed for the fields.</param>
    /// <param name="Title">The title of the assisted setup.</param>
    /// <param name="ShortTitle">The short title of the assisted setup.</param>
    /// <param name="Description">The description of the assisted setup.</param>
    /// <param name="ExpectedDuration">The expected duration of the assisted setup.</param>
    /// <param name="ObjectTypeToRun">The object type of the assisted setup.</param>
    /// <param name="ObjectIDToRun">The object id of the assisted setup.</param>
    /// <param name="AssistedSetupGroup">The group of the assisted setup.</param>
    /// <param name="VideoUrl">The video URL of the assisted setup.</param>
    /// <param name="VideoCategory">The video category of the assisted setup.</param>
    /// <param name="HelpUrl">The help URL of the assisted setup.</param>
    procedure InsertAssistedSetup(ShouldRandomizeFields: Boolean; var Title: Text[2048]; var ShortTitle: Text[50]; var Description: Text[1024]; var ExpectedDuration: Integer; ObjectTypeToRun: ObjectType; ObjectIDToRun: Integer; AssistedSetupGroup: Enum "Assisted Setup Group"; var VideoUrl: Text[250]; VideoCategory: Enum "Video Category"; var HelpUrl: Text[250])
    var
        GuidedExperience: Codeunit "Guided Experience";
    begin
        if ShouldRandomizeFields then begin
            GetFields(Title, ShortTitle, Description, ExpectedDuration);

            VideoUrl := CopyStr(Any.AlphanumericText(MaxStrLen(VideoUrl)), 1, MaxStrLen(VideoUrl));
            HelpUrl := CopyStr(Any.AlphanumericText(MaxStrLen(HelpUrl)), 1, MaxStrLen(HelpUrl));
        end;

        GuidedExperience.InsertAssistedSetup(Title, ShortTitle, Description, ExpectedDuration, ObjectTypeToRun,
            ObjectIDToRun, AssistedSetupGroup, VideoUrl, VideoCategory::Uncategorized, HelpUrl);
    end;

    /// <summary>
    /// Inserts a new manual setup guided experience item.
    /// </summary>
    /// <param name="ShouldRandomizeFields">If true, the values of the fields that are passed by var will be randomized. If false, it will insert the record with the values that were passed for the fields.</param>
    /// <param name="Title">The title of the manual setup.</param>
    /// <param name="ShortTitle">The short title of the manual setup.</param>
    /// <param name="Description">The description of the manual setup.</param>
    /// <param name="ExpectedDuration">The expected duration of the manual setup.</param>
    /// <param name="ObjectTypeToRun">The object type of the manual setup.</param>
    /// <param name="ObjectIDToRun">The object id of the manual setup.</param>
    /// <param name="ManualSetupCategory">The category of the manual setup.</param>
    /// <param name="Keywords">The keywords of the manual setup.</param>
    procedure InsertManualSetup(ShouldRandomizeFields: Boolean; var Title: Text[2048]; var ShortTitle: Text[50]; var Description: Text[1024]; var ExpectedDuration: Integer; ObjectTypeToRun: ObjectType; ObjectIDToRun: Integer; ManualSetupCategory: Enum "Manual Setup Category"; var Keywords: Text[250])
    var
        GuidedExperience: Codeunit "Guided Experience";
    begin
        if ShouldRandomizeFields then begin
            GetFields(Title, ShortTitle, Description, ExpectedDuration);

            Keywords := CopyStr(Any.AlphanumericText(MaxStrLen(Keywords)), 1, MaxStrLen(Keywords));
        end;

        GuidedExperience.InsertManualSetup(Title, ShortTitle, Description, ExpectedDuration, ObjectTypeToRun,
            ObjectIDToRun, ManualSetupCategory, Keywords);
    end;

    /// <summary>
    /// Inserts a new learn link guided experience item.
    /// </summary>
    /// <param name="ShouldRandomizeFields">If true, the values of the fields that are passed by var will be randomized. If false, it will insert the record with the values that were passed for the fields.</param>
    /// <param name="Title">The title of the learn link.</param>
    /// <param name="ShortTitle">The short title of the learn link.</param>
    /// <param name="Description">The description of the learn link.</param>
    /// <param name="ExpectedDuration">The expected duration of the learn link.</param>
    /// <param name="LinkToRun">The link to run.</param>
    procedure InsertLearnLink(ShouldRandomizeFields: Boolean; var Title: Text[2048]; var ShortTitle: Text[50]; var Description: Text[1024]; var ExpectedDuration: Integer; LinkToRun: Text[250])
    var
        GuidedExperience: Codeunit "Guided Experience";
    begin
        if ShouldRandomizeFields then
            GetFields(Title, ShortTitle, Description, ExpectedDuration);

        GuidedExperience.InsertLearnLink(Title, ShortTitle, Description, ExpectedDuration, LinkToRun);
    end;

    /// <summary>
    /// Inserts a new application feature guided experience item.
    /// </summary>
    /// <param name="ShouldRandomizeFields">If true, the values of the fields that are passed by var will be randomized. If false, it will insert the record with the values that were passed for the fields.</param>
    /// <param name="Title">The title of the application feature.</param>
    /// <param name="ShortTitle">The short title of the application feature.</param>
    /// <param name="Description">The description of the application feature.</param>
    /// <param name="ExpectedDuration">The expected duration of the application feature.</param>
    /// <param name="ObjectTypeToRun">The object type of the application feature.</param>
    /// <param name="ObjectIDToRun">The object id of the application feature.</param>
    procedure InsertApplicationFeature(ShouldRandomizeFields: Boolean; var Title: Text[2048]; var ShortTitle: Text[50]; var Description: Text[1024]; var ExpectedDuration: Integer; ObjectTypeToRun: ObjectType; ObjectIDToRun: Integer)
    var
        GuidedExperience: Codeunit "Guided Experience";
    begin
        if ShouldRandomizeFields then
            GetFields(Title, ShortTitle, Description, ExpectedDuration);

        GuidedExperience.InsertApplicationFeature(Title, ShortTitle, Description,
            ExpectedDuration, ObjectTypeToRun, ObjectIDToRun);
    end;

    /// <summary>
    /// Inserts a new video guided experience item.
    /// </summary>
    /// <param name="ShouldRandomizeFields">If true, the values of the fields that are passed by var will be randomized. If false, it will insert the record with the values that were passed for the fields.</param>
    /// <param name="Title">The title of the video.</param>
    /// <param name="ShortTitle">The short title of the video.</param>
    /// <param name="Description">The description of the videok.</param>
    /// <param name="ExpectedDuration">The expected duration of the video.</param>
    /// <param name="VideoUrl">The video URL.</param>
    procedure InsertVideo(ShouldRandomizeFields: Boolean; var Title: Text[2048]; var ShortTitle: Text[50]; var Description: Text[1024]; var ExpectedDuration: Integer; VideoUrl: Text[250]; VideoCategory: Enum "Video Category")
    var
        GuidedExperience: Codeunit "Guided Experience";
    begin
        if ShouldRandomizeFields then
            GetFields(Title, ShortTitle, Description, ExpectedDuration);

        GuidedExperience.InsertVideo(Title, ShortTitle, Description, ExpectedDuration, VideoUrl, VideoCategory);
    end;

    /// <summary>
    /// Inserts a new tour guided experience item.
    /// </summary>
    /// <param name="ShouldRandomizeFields">If true, the values of the fields that are passed by var will be randomized. If false, it will insert the record with the values that were passed for the fields.</param>
    /// <param name="Title">The title of the tour.</param>
    /// <param name="ShortTitle">The short title of the tour.</param>
    /// <param name="Description">The description of the tour.</param>
    /// <param name="ExpectedDuration">The expected duration of the tour.</param>
    /// <param name="PageID">The id of the page that the spotlight tour is run on.</param>
    procedure InsertTour(ShouldRandomizeFields: Boolean; var Title: Text[2048]; var ShortTitle: Text[50]; var Description: Text[1024]; var ExpectedDuration: Integer; PageID: Integer)
    var
        GuidedExperience: Codeunit "Guided Experience";
    begin
        if ShouldRandomizeFields then
            GetFields(Title, ShortTitle, Description, ExpectedDuration);

        GuidedExperience.InsertTour(Title, ShortTitle, Description, ExpectedDuration, PageID);
    end;

    /// <summary>
    /// Inserts a new spotlight tour guided experience item.
    /// </summary>
    /// <param name="ShouldRandomizeFields">If true, the values of the fields that are passed by var will be randomized. If false, it will insert the record with the values that were passed for the fields.</param>
    /// <param name="Title">The title of the spotlight tour.</param>
    /// <param name="ShortTitle">The short title of spotlight the tour.</param>
    /// <param name="Description">The description of the spotlight tour.</param>
    /// <param name="ExpectedDuration">The expected duration spotlight of the tour.</param>
    /// <param name="PageID">The id of the page that the spotlight tour is run on.</param>
    /// <param name="SpotlightTourType">The type of spotlight tour.</param>
    /// <param name="SpotlightTourTexts">The texts that should be displayed during the spotlight tour.</param>
    procedure InsertSpotlightTour(ShouldRandomizeFields: Boolean; var Title: Text[2048]; var ShortTitle: Text[50]; var Description: Text[1024]; var ExpectedDuration: Integer; PageID: Integer; SpotlightTourType: Enum "Spotlight Tour Type"; var SpotlightTourTexts: Dictionary of [Enum "Spotlight Tour Text", Text])
    var
        GuidedExperience: Codeunit "Guided Experience";
    begin
        if ShouldRandomizeFields then begin
            GetFields(Title, ShortTitle, Description, ExpectedDuration);

            GetSpotlightTourTexts(SpotlightTourTexts);
        end;

        GuidedExperience.InsertSpotlightTour(Title, ShortTitle, Description, ExpectedDuration,
            PageID, SpotlightTourType, SpotlightTourTexts);
    end;

    local procedure GetFields(var Title: Text[2048]; var ShortTitle: Text[50]; var Description: Text[1024]; var ExpectedDuration: Integer)
    begin
        Title := CopyStr(Any.AlphanumericText(MaxStrLen(Title)), 1, MaxStrLen(Title));
        ShortTitle := CopyStr(Any.AlphanumericText(MaxStrLen(ShortTitle)), 1, MaxStrLen(ShortTitle));
        Description := CopyStr(Any.AlphanumericText(MaxStrLen(Description)), 1, MaxStrLen(Description));
        ExpectedDuration := Any.IntegerInRange(1000);
    end;

    local procedure GetSpotlightTourTexts(var SpotlightTourTexts: Dictionary of [Enum "Spotlight Tour Text", Text])
    var
        SpotlightTourText: Enum "Spotlight Tour Text";
    begin
        foreach SpotlightTourText in SpotlightTourText.Ordinals() do begin
            if SpotlightTourTexts.ContainsKey(SpotlightTourText) then
                SpotlightTourTexts.Remove(SpotlightTourText);

            SpotlightTourTexts.Add(SpotlightTourText, Any.AlphanumericText(250));
        end;
    end;
}