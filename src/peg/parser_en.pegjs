
StandupNote
  = who:Who Blanks yesterday:Yesterday? Blanks today:Today? Blanks blockers:Blockers? Blanks
  { return { who, yesterday, today, blockers }; }

Blanks
  = '\n'*

Who
  = '#' ' '* name:Name ', ' date:Date '\n'
  { return { name, date }; }

Name
  = name:(!" Standup" .)* " Standup"
  { return name.map(chb => chb[1]).join(''); }

Digit
  = [0-9]

Date
  = Day ' ' date:Date2 { return date; }
  / Day ' ' date:Date4 { return date; }
  / date:Date2         { return date; }
  / date:Date4         { return date; }

Day
  = 'Monday'i    / 'Mon'i
  / 'Tuesday'i   / 'Tues'i  / 'Tue'i
  / 'Wednesday'i / 'Weds'i  / 'Wed'i
  / 'Thursday'i  / 'Thurs'i / 'Thur'i / 'Thu'i 
  / 'Friday'i    / 'Fri'i
  / 'Saturday'i  / 'Sat'i
  / 'Sunday'i    / 'Sun'i;

DateSep
  = '-'
  / '/'

Bullet
  = '*'
  / '-'

Date4
  = Digit Digit? DateSep Digit Digit? DateSep Digit Digit Digit Digit
  { return text(); }

Date2
  = Digit Digit? DateSep Digit Digit? DateSep Digit Digit
  { return text(); }

Text
  = t:(!'\n' .)* '\n'
  { return t.map(chb => chb[1]).join(''); }

ListItem
  = '  '* b:Bullet ' '* text:Text
  { return text; }

YesterdayHeader
  = '##' ' '* 'Yesterday, I' ':'? '\n'

Yesterday
  = YesterdayHeader l:ListItem*
  { return l; }

TodayHeader =
  '##' ' '* 'Today, I' ':'? '\n'

Today
  = TodayHeader l:ListItem*
  { return l; }

BlockersHeader = 
  '##' ' '* 'Blockers' ':'? '\n'

Blockers
  = BlockersHeader l:ListItem*
  { return l; }
