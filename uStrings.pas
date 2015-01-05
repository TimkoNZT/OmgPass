unit uStrings;
interface
const
    //xmlMain
    CrLf = sLineBreak;
    strDefaultExt = '.xml';
    strCryptedExt = '.opwd';
    strRootNode = 'Root';
    strHeaderNode = 'Header';
    strDataNode = 'Data';
    strFolderNode = 'Folder';
    strItemNode = 'Item';
    strDefItemNode = 'DefItem';
    strConfigFile = 'config.xml';
    strLink = 'https://cloud.mail.ru/public/86079c1768cf/OmgPass/';

resourcestring
    rsTypes ='Title|Text|Pass|Link|Memo|Date|Mail|File';
    rsTitleDefName = 'Title';
    rsTextDefName = 'Login';
    rsPassDefName = 'Password';
    rsCommentDefName = 'Comment';
    rsLinkDefName = 'Website';
    rsDateDefName = 'Date';
    rsMailDefName = 'Mail';
    rsFileDefName = 'File';
    //Название новой записи, папки, страницы
    rsNewItemTitle = 'New record';
    rsNewFolderTitle = 'New folder';
    rsNewPageTitle = 'New Page';
    //Серый текст в поле поиска
    rsSearchText = 'Search';
    //Инфо блок для папок
    rsInfoTitle =           'Title: ';
    rsInfoSubfolders =      'Subfolders:       ';
    rsInfoTotalFolders =    'Total folders:    ';
    rsInfoSubItems =        'Subitems:         ';
    rsInfoTotalItems =      'Total items:      ';
    //MessageBoxes
    rsDelFieldConfirmationText = 'Confirm to delete field "%s"?' + CrLf + 'Value will be deleted too';
    rsDelFieldConfirmationCaption = 'Deleting field';
    rsCantDelTitleField = 'Can''t delete unique title of record';
    //DeleteNode
    rsDelNodeTitle = 'Deleting';
    rsDelItem = 'Warning!' + CrLf + 'Are you sure you want to delete the record %s?';
    rsDelFolder ='Warning!' + CrLf + 'Are you sure you want to delete the folder %s?' +
                               CrLf + 'This will delete all subfolders and records!';
    rsDelPage = 'WARNING!' + CrLf + 'Are you sure you want to delete the page %s?' +
                                CrLf + 'This will delete all subfolders and records!!!' +
                                CrLf + 'CONFIRM DELETING?';
    rsCantDelPage =  'Sorry! Can''t delete unique page.';
//    rsChangeTitleWarningCaption = 'Deleting field';
//    rsChangeTitleWarning = 'Can''t change format for only title of record';
    rsFieldNotSelected = 'Field not selected';
    rsDemo = 'Sorry, you''ve reached the limit of the records count for the test version of program';
    rsDocumentIsEmpty = 'Hmm, it looks like your document is empty!' + CrLf +
                        'Before working with the document,' + CrLf +
                        'you must add at least one page.' + CrLf + CrLf +
                        'Would you like to add new page?';
    rsDocumentIsEmptyTitle = 'Ooops!';
    //
    //
    const arrFieldFormats: array[0..8] of String = ('title',
                                                'text',
                                                'pass',
                                                'web',
                                                'comment',
                                                'date',
                                                'mail',
                                                'file',
                                                '');

    const arrNodeTypes: array[0..9] of String = ('root',
                                                'header',
                                                'data',
                                                'page',
                                                'folder',
                                                'deffolder',
                                                'item',
                                                'defitem',
                                                'field',
                                                '');

    const arrDefFieldNames: array[0..8] of String = ('Title',
                                                    'Login',
                                                    'Password',
                                                    'Website',
                                                    'Comment',
                                                    'Date',
                                                    'Mail',
                                                    'File',
                                                    'Text or Login');
    //Window captions
    //Заголовки окошек
    rsFrmAccountsCaption = ' welcomes you!';
    rsFrmAccountsCaptionOpen = 'Open base';
    rsFrmAccountsCaptionChange = ' - Document manager';
    rsFrmEditItemCaption = 'Edit record';
    rsFrmEditItemCaptionDef = 'Edit default record';
    rsFrmEditItemCaptionNew = 'New record';
    rsFrmEditFieldCaption = 'Edit field properties';
    rsFrmEditFieldCaptionNew = 'New field...';

    //Modal buttons
    //Модальные кнопочки
    rsClose = 'Close';
    rsCancel = 'Cancel';
    rsOK = 'OK';
    rsExit = 'Exit';
    rsOpen = 'Open';
    rsCopy = 'Copy';

    //Smart-buttons hints
    //Подсказки для кнопулек
    rsHintOpenLink = 'Open link';
    rsHintCopyToClipboard = 'Copy to clipboard';
    rsHintCopyFromClipboard = 'Copy from clipboard';
    rsHintGenerate = 'Generate password';
    rsHintEditField = 'Edit field properties';
    rsHintSaveFile = 'Save file(s)';
    rsHintAddFile = 'Add file(s)';

    //frmAccounts
    rsSaveDialogFilter = 'Omg!Pass XML|*.xml|Omg!Pass Crypted|*.opwd';
    rsOpenDialogFilter = 'Omg!Pass XML|*.xml|Omg!Pass Crypted|*.opwd|All files|*.*';
    rsFileNotFoundMsg = 'File not found on the stored path!' +
                         CrLf + 'Would you like to create a new document' +
                         CrLf + '%s ?';
    rsFileNotFoundMsgTitle = 'File not found';
    rsSaveDialogFileExists = 'You have selected an existing file:' + CrLf + '%s' + CrLf+ 'Overwrite it?';
    rsSaveDialogTitle = 'Save new database as...';
    rsOpenDialogTitle = 'Open database...';
    rsOpenDocumentError = 'Can''t open %s' + CrLf + 'Please, make sure it is the correct file.';
    rsOpenDocumentErrorTitle = 'Open document error';
    rsTxtPassFileNotFound = 'File not found';
    rsTxtPassFileIsBad = 'Bad or corupted file';
    rsTxtPassPassNotReq = 'Not required';
    //frmMain

    //
implementation
end.
