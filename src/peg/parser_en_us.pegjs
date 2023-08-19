
{


  function null_to_arr(noa) {
    return noa === null? [] : noa;
  }


  function nest(items) {

    if (items.length === 0) { return items; }

    const new_items = [],
          stack     = [ [new_items, items[0].depth] ];

    for (let i=0, iC=items.length; i<iC; ++i) {

      if (items[i].depth === stack[0][1]) {

        delete items[i].depth;
        stack[0][0].push(items[i]);

      } else if (items[i].depth > stack[0][1]) {

        let nc = new_items[new_items.length-1];

        while ((nc.children !== undefined) && (nc.children.length)) {
          nc = nc.children[nc.children.length-1];
        }

        if (nc.children === undefined) { nc.children = []; }
        stack.unshift( [ nc.children, items[i].depth ] );
        delete items[i].depth;
        stack[0][0].push(items[i]);

      } else {

        while (items[i].depth < stack[0][1]) {

          if (stack.length) {
            stack.shift();
          } else {
            throw new Error('Depth error');
          }

        }

        delete items[i].depth;
        stack[0][0].push(items[i]);

      }
    }

    return new_items;

  }


  function process_block(block) {
    const base = null_to_arr(block).filter(l => l.text.length);
    return nest(base, base[0] ?? {}.depth);
  }


  function process(final) {
    return {
      who       : final.who,
      yesterday : process_block(final.yesterday),
      today     : process_block(final.today),
      blockers  : process_block(final.blockers),
      off       : process_block(final.off)
    }
  }


}





StandupNote
  = who:Who Blanks off:Off? Blanks yesterday:Yesterday? Blanks today:Today? Blanks blockers:Blockers? Blanks
  { return process({ who, yesterday, today, blockers, off }); }

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
  = m1:Digit m2:Digit? DateSep Digit Digit? DateSep Digit Digit Digit Digit
  { return text(); }

Date2
  = m1:Digit m2:Digit? DateSep d1:Digit d2:Digit? DateSep y1:Digit y2:Digit
  { return { month : Number(`${m1}${m2 || ''}`),
             day   : Number(`${d1}${d2 || ''}`),
             year  : Number(`20${y1}${y2 || ''}`)  }; }

Text
  = t:(!'\n' .)* '\n'
  { return t.map(chb => chb[1]).join(''); }

ListSpacer
  = '  '
  / '\t'

ListItem
  = depth:ListSpacer* b:Bullet ' '* text:Text
  { return { text, depth: depth.length }; }

OffCause
  = 'Holiday'i
  / 'Sick'i / 'Out sick'i
  / 'Vacation'i
  / 'No work'i
  / 'Outage'i
  / 'Not scheduled'i

Off
  = '##' ' '* cause:OffCause extra:(!'\n' .)* '\n'
  { return { cause, extra: extra.map(chb => chb[1]).join('') }; }

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
