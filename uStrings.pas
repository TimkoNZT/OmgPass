unit uStrings;
interface
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
    rsNewItemTitle = 'New item';
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
    rsDelFieldConfirmationText = 'Confirm to delete field "%s"?' + #10#13 + 'Value will be deleted too';
    rsDelFieldConfirmationCaption = 'Deleting field';
    rsCantDelTitleField = 'Can''t delete title of record';
    rsFieldNotSelected = 'Field not selected';
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
    //Заголовки окошек
    rsFrmAccountsCaption = 'Account manager';
    rsFrmAccountsCaptionOpen = 'Open base';
    rsFrmAccountsCaptionChange = 'Change base';
    rsFrmEditItemCaption = 'Edit record';
    rsFrmEditItemCaptionNew = 'New record';
    rsFrmEditFieldCaption = 'Edit field properties';
    rsFrmEditFieldCaptionNew = 'New field...';

    //Модальные кнопочки
    rsClose = 'Close';
    rsCancel = 'Cancel';
    rsOK = 'OK';
    rsExit = 'Exit';
    rsOpen = 'Open';

    //frmAccounts

    //frmMain

    //
implementation
end.
