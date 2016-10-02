//
//  JTCalendarProtocols.swift
//  Pods
//
//  Created by JayT on 2016-06-07.
//
//

struct CalendarData {
    var months: [Month]
    var totalSections: Int
    var monthMap: [Int:Int]
    var totalDays: Int
}

struct Month {
    let startDayIndex: Int      // Start index day for the month. The start is total number of days of previous months
    let startCellIndex: Int     // Start cell index for the month. The start is total number of cells of previous months
    let sections: [Int]         // The total number of items in this array are the total number of sections. The actual number is the number of items in each section
    let preDates: Int
    let postDates: Int
    let sectionIndexMaps: [Int:Int] // Maps a section to the index in the total number of sections
    let rows: Int                   // Number of rows for the month
    // Return the total number of days for the represented month
    var numberOfDaysInMonth: Int {
        get { return numberOfDaysInMonthGrid - preDates - postDates }
    }
    // Return the total number of day cells to generate for the represented month
    var numberOfDaysInMonthGrid: Int {
        get { return sections.reduce(0, +) }
    }
    var startSection: Int {
        return sectionIndexMaps.keys.min()!
    }
    // Return the section in which a day is contained
    func indexPath(forDay number: Int) -> IndexPath? {
        var variableNumber = number
        let possibleSection = sections.index {
            let retval = variableNumber + preDates <= $0
            variableNumber -= $0
            return retval
        }!
        let theSection = sectionIndexMaps.key(for: possibleSection)!

        let dateOfStartIndex = sections[0..<possibleSection].reduce(0, +) - preDates + 1
        let itemIndex = number - dateOfStartIndex

        return IndexPath(item: itemIndex, section: theSection)
    }
    
    // Return the number of rows for a section in the month
//    func numberOfRows(for section: Int, developerSetRows: Int) -> Int? {
//        var retval: Int?
//        guard let  theSection = sectionIndexMaps[section] else {
//            return nil
//        }
//        let fullRows = rows / developerSetRows
//        let partial = sections.count - fullRows
//        
//        if theSection + 1 <= fullRows {
//            retval = developerSetRows
//        } else if fullRows == 0 && partial > 0 {
//            retval = rows
//        } else {
//            retval = 1
//        }
//        return retval
//    }
    // Returns the maximum number of a rows for a completely full section
    func maxNumberOfRowsForFull(developerSetRows: Int) -> Int {
        var retval: Int
        let fullRows = rows / developerSetRows
        if fullRows < 1 {
            retval = rows
        } else {
            retval = developerSetRows
        }
        return retval
    }
}

enum JTAppleCalendarViewSource {
    case fromXib(String, Bundle?)
    case fromType(AnyClass)
    case fromClassName(String, Bundle?)
}


/// Default delegate functions
public extension JTAppleCalendarViewDelegate {
    func calendar(_ calendar: JTAppleCalendarView, canSelectDate date: Date, cell: JTAppleDayCellView, cellState: CellState) -> Bool { return true }
    func calendar(_ calendar: JTAppleCalendarView, canDeselectDate date: Date, cell: JTAppleDayCellView, cellState: CellState) -> Bool {return true}
    func calendar(_ calendar: JTAppleCalendarView, didSelectDate date: Date, cell: JTAppleDayCellView?, cellState: CellState) {}
    func calendar(_ calendar: JTAppleCalendarView, didDeselectDate date: Date, cell: JTAppleDayCellView?, cellState: CellState) {}
    func calendar(_ calendar: JTAppleCalendarView, didScrollToDateSegmentFor range: (start: Date, end: Date), belongingTo month: Int) {}
    func calendar(_ calendar: JTAppleCalendarView, willDisplayCell cell: JTAppleDayCellView, date: Date, cellState: CellState) {}
    func calendar(_ calendar: JTAppleCalendarView, willResetCell cell: JTAppleDayCellView) {}
    func calendar(_ calendar: JTAppleCalendarView, willDisplaySectionHeader header: JTAppleHeaderView, range: (start: Date, end: Date), identifier: String) {}
    func calendar(_ calendar: JTAppleCalendarView, sectionHeaderIdentifierFor range: (start: Date, end: Date), belongingTo month: Int) -> String {return ""}
    func calendar(_ calendar: JTAppleCalendarView, sectionHeaderSizeFor range: (start: Date, end: Date), belongingTo month: Int) -> CGSize {return CGSize.zero}
}

/// The JTAppleCalendarViewDataSource protocol is adopted by an object that mediates the application’s data model for a JTAppleCalendarViewDataSource object.
/// The data source provides the calendar-view object with the information it needs to construct and modify it self
public protocol JTAppleCalendarViewDataSource: class {
    /// Asks the data source to return the start and end boundary dates as well as the calendar to use. You should properly configure your calendar at this point.
    /// - Parameters:
    ///     - calendar: The JTAppleCalendar view requesting this information.
    /// - returns:
    ///     - startDate: The *start* boundary date for your calendarView.
    ///     - endDate: The *end* boundary date for your calendarView.
    ///     - numberOfRows: The number of rows to be displayed per month
    ///     - calendar: The *calendar* to be used by the calendarView.
    func configureCalendar(_ calendar: JTAppleCalendarView) -> ConfigurationParameters
}


/// The delegate of a JTAppleCalendarView object must adopt the JTAppleCalendarViewDelegate protocol.
/// Optional methods of the protocol allow the delegate to manage selections, and configure the cells.
public protocol JTAppleCalendarViewDelegate: class {
    /// Asks the delegate if selecting the date-cell with a specified date is allowed
    /// - Parameters:
    ///     - calendar: The JTAppleCalendar view requesting this information.
    ///     - date: The date attached to the date-cell.
    ///     - cell: The date-cell view. This can be customized at this point.
    ///     - cellState: The month the date-cell belongs to.
    /// - returns: A Bool value indicating if the operation can be done.
    func calendar(_ calendar: JTAppleCalendarView, canSelectDate date: Date, cell: JTAppleDayCellView, cellState: CellState) -> Bool
    /// Asks the delegate if de-selecting the date-cell with a specified date is allowed
    /// - Parameters:
    ///     - calendar: The JTAppleCalendar view requesting this information.
    ///     - date: The date attached to the date-cell.
    ///     - cell: The date-cell view. This can be customized at this point.
    ///     - cellState: The month the date-cell belongs to.
    /// - returns: A Bool value indicating if the operation can be done.
    func calendar(_ calendar: JTAppleCalendarView, canDeselectDate date: Date, cell: JTAppleDayCellView, cellState: CellState) -> Bool
    /// Tells the delegate that a date-cell with a specified date was selected
    /// - Parameters:
    ///     - calendar: The JTAppleCalendar view giving this information.
    ///     - date: The date attached to the date-cell.
    ///     - cell: The date-cell view. This can be customized at this point. This may be nil if the selected cell is off the screen
    ///     - cellState: The month the date-cell belongs to.
    func calendar(_ calendar: JTAppleCalendarView, didSelectDate date: Date, cell: JTAppleDayCellView?, cellState: CellState)
    /// Tells the delegate that a date-cell with a specified date was de-selected
    /// - Parameters:
    ///     - calendar: The JTAppleCalendar view giving this information.
    ///     - date: The date attached to the date-cell.
    ///     - cell: The date-cell view. This can be customized at this point. This may be nil if the selected cell is off the screen
    ///     - cellState: The month the date-cell belongs to.
    func calendar(_ calendar: JTAppleCalendarView, didDeselectDate date: Date, cell: JTAppleDayCellView?, cellState: CellState)
    /// Tells the delegate that the JTAppleCalendar view scrolled to a segment beginning and ending with a particular date
    /// - Parameters:
    ///     - calendar: The JTAppleCalendar view giving this information.
    ///     - startDate: The date at the start of the segment.
    ///     - endDate: The date at the end of the segment.
    func calendar(_ calendar: JTAppleCalendarView, didScrollToDateSegmentFor range: (start: Date, end: Date), belongingTo month: Int)
    /// Tells the delegate that the JTAppleCalendar is about to display a date-cell. This is the point of customization for your date cells
    /// - Parameters:
    ///     - calendar: The JTAppleCalendar view giving this information.
    ///     - cell: The date-cell that is about to be displayed.
    ///     - date: The date attached to the cell.
    ///     - cellState: The month the date-cell belongs to.
    func calendar(_ calendar: JTAppleCalendarView, willDisplayCell cell: JTAppleDayCellView, date: Date, cellState: CellState)
    /// Tells the delegate that the JTAppleCalendar is about to reset a date-cell. Reset your cell here before being reused on screen. Make sure this function exits quicky.
    /// - Parameters:
    ///     - cell: The date-cell that is about to be reset.
    func calendar(_ calendar: JTAppleCalendarView, willResetCell cell: JTAppleDayCellView)
    /// Implement this function to use headers in your project. Return your registered header for the date presented.
    /// - Parameters:
    ///     - date: Contains the startDate and endDate for the header that is about to be displayed
    /// - Returns:
    ///   String: Provide the registered header you wish to show for this date
    func calendar(_ calendar: JTAppleCalendarView, sectionHeaderIdentifierFor range: (start: Date, end: Date), belongingTo month: Int) -> String
    /// Implement this function to use headers in your project. Return the size for the header you wish to present
    /// - Parameters:
    ///     - date: Contains the startDate and endDate for the header that is about to be displayed
    /// - Returns:
    ///   CGSize: Provide the size for the header you wish to show for this date
    func calendar(_ calendar: JTAppleCalendarView, sectionHeaderSizeFor range: (start: Date, end: Date), belongingTo month: Int) -> CGSize
    /// Tells the delegate that the JTAppleCalendar is about to display a header. This is the point of customization for your headers
    /// - Parameters:
    ///     - calendar: The JTAppleCalendar view giving this information.
    ///     - header: The header view that is about to be displayed.
    ///     - date: The date attached to the header.
    ///     - identifier: The identifier you provided for the header
    func calendar(_ calendar: JTAppleCalendarView, willDisplaySectionHeader header: JTAppleHeaderView, range: (start: Date, end: Date), identifier: String)
}

protocol JTAppleCalendarLayoutProtocol: class {
    var itemSize: CGSize {get set}
    var headerReferenceSize: CGSize {get set}
    var scrollDirection: UICollectionViewScrollDirection {get set}
    var cellCache: [Int:[UICollectionViewLayoutAttributes]] {get set}
    var headerCache: [Int: UICollectionViewLayoutAttributes] {get set}
    var sectionSize: [CGFloat] {get set}
    func targetContentOffsetForProposedContentOffset(_ proposedContentOffset: CGPoint) -> CGPoint
    func sectionFromRectOffset(_ offset: CGPoint) -> Int
    func sectionFromOffset(_ theOffSet: CGFloat) -> Int
    func sizeOfContentForSection(_ section: Int) -> CGFloat
    func clearCache()
    func prepare()
}

protocol JTAppleCalendarDelegateProtocol: class {
    var itemSize: CGFloat? {get set}
    var registeredHeaderViews: [JTAppleCalendarViewSource] {get set}
    var cachedConfiguration: ConfigurationParameters {get set}
    var monthInfo: [Month] {get set}
    var monthMap: [Int:Int] {get set}
    var totalMonthSections: Int {get}
    var totalDays: Int {get}
    
    func numberOfRows() -> Int
    func cachedDate() -> (start: Date, end: Date, calendar: Calendar)
    func numberOfsections(forMonth section: Int) -> Int
    func numberOfMonthsInCalendar() -> Int
    func numberOfPreDatesForMonth(_ month: Date) -> Int
    
    func referenceSizeForHeaderInSection(_ section: Int) -> CGSize
    func firstDayIndexForMonth(_ date: Date) -> Int
    func rowsAreStatic() -> Bool
    func preDatesAreGenerated() -> Bool
    func postDatesAreGenerated() -> OutDateCellGeneration
}

internal protocol JTAppleReusableViewProtocolTrait: class {
    associatedtype ViewType: UIView
    func setupView(_ cellSource: JTAppleCalendarViewSource)
    var view: ViewType? {get set}
}

extension JTAppleReusableViewProtocolTrait {
    func setupView(_ cellSource: JTAppleCalendarViewSource) {
        if view != nil { return}
        switch cellSource {
        case let .fromXib(xibName, bundle):
            let bundleToUse = bundle ?? Bundle.main
            let viewObject = bundleToUse.loadNibNamed(xibName, owner: self, options: [:])
            guard let view = viewObject?[0] as? ViewType else {
                print("xib: \(xibName),  file class does not conform to the JTAppleViewProtocol")
                assert(false)
                return
            }
            self.view = view
            break
        case let .fromClassName(className, bundle):
            let bundleToUse = bundle ?? Bundle.main
            guard let theCellClass = bundleToUse.classNamed(className) as? ViewType.Type else {
                print("Error loading registered class: '\(className)'")
                print("Make sure that: \n\n(1) It is a subclass of: 'UIView' and conforms to 'JTAppleViewProtocol'")
                print("(2) You registered your class using the fully qualified name like so -->  'theNameOfYourProject.theNameOfYourClass'\n")
                assert(false)
                return
            }
            self.view = theCellClass.init()
            break
        case let .fromType(cellType):
            guard let theCellClass = cellType as? ViewType.Type else {
                print("Error loading registered class: '\(cellType)'")
                print("Make sure that: \n\n(1) It is a subclass of: 'UIiew' and conforms to 'JTAppleViewProtocol'\n")
                assert(false)
                return
            }
            self.view = theCellClass.init()
            break
        }
        guard
            let validSelf = self as? UIView,
            let validView = view else {
                print("Error setting up views. \(developerErrorMessage)")
                return
        }
        validSelf.addSubview(validView)
    }
}
