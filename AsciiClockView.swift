import ScreenSaver
import Cocoa
import CoreGraphics
class AsciiClockView: ScreenSaverView{
    // MARK: - Ascii Constants
    let container = """
     _______________________________________________________
     /=======================================================\\
     ||                                                      ||
     ||                                                      ||
     ||                                                      ||
     ||                               ||
     ||                               ||
     ||                            ||
     ||                               ||
     ||                            ||
     ||                                                      ||
     ||                                          ||
     ||                                                      ||
     \\=======================================================/
     ‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾
    """

    let asciiArtDigits = [
        """
         0000\u{0020}
        00  00
        00  00
        00  00
         0000\u{0020}
        """,
        """
        1111\u{0020}\u{0020}
          11\u{0020}\u{0020}
          11\u{0020}\u{0020}
          11\u{0020}\u{0020}
        111111
        """,
        """
         2222\u{0020}
        22  22
           22\u{0020}
         22\u{0020}\u{0020}\u{0020}
        222222
        """,
        """
         3333\u{0020}
        33  33
           333
        33  33
         3333\u{0020}
        """,
        """
        44  44
        44  44
        444444
            44
            44
        """,
        """
        555555
        55\u{0020}\u{0020}\u{0020}\u{0020}
        55555\u{0020}
            55
        55555\u{0020}
        """,
        """
         6666\u{0020}
        66\u{0020}\u{0020}\u{0020}\u{0020}
        66666\u{0020}
        66  66
         6666\u{0020}
        """,
        """
        777777
           77\u{0020}
          77\u{0020}\u{0020}
         77\u{0020}\u{0020}\u{0020}
        77\u{0020}\u{0020}\u{0020}\u{0020}
        """,
        """
         8888\u{0020}
        88  88
         8888\u{0020}
        88  88
         8888\u{0020}
        """,
        """
         9999\u{0020}
        99  99
         99999
            99
         9999\u{0020}
        """
    ]

    let colon: [[Character]] = [
        [" ", ":", ":", " "],
        [" ", ":", ":", " "],
        [" ", " ", " ", " "],
        [" ", ":", ":", " "],
        [" ", ":", ":", " "]
    ]
    //MARK: - Globals
    var slicedContainer:[String] = []
    var am:Bool = true
    let userCalendar = Calendar.current
    
    let digitWidth = 6
    let digitHeight = 5
    var slicedDigits: [[[Character]]] = []
    var clockPosition: NSPoint = NSPoint()
    var clockSize: NSSize = NSSize()
    var targetPosition: NSPoint = NSPoint()
    var initialized = false

    //MARK: - Initializer Funcs
    func getColonRow(row:Int) -> String{
        return String(colon[row])
    }
    private func sliceDigits() -> [[[Character]]]{
      var digits = [[[Character]]]()
      for digit in asciiArtDigits{
        let lines = digit.split(separator: "\n")
        var asciiArray = [[Character]]()
        for line in lines{
          let chars = Array(line)
          asciiArray.append(chars)
        }
        digits.append(asciiArray)
      }
      return digits
    }

    private func sliceContainer() -> [String]{
      let subs = container.split(separator: "\n")
      let strings = subs.map{String($0)}
      return strings
    }
    
    // MARK: - Initialization
    override init?(frame: NSRect, isPreview: Bool) {
        super.init(frame: frame, isPreview: isPreview)
        self.slicedDigits = sliceDigits()
        self.slicedContainer = sliceContainer()
    }

    @available(*, unavailable)
    required init?(coder decoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    // MARK: - Lifecycle
    override func draw(_ rect: NSRect) {
        drawBackground(.black)
        updatePosition()
        drawTime()
    }

    private func drawBackground(_ color: NSColor) {
        let background = NSBezierPath(rect: bounds)
        color.setFill()
        background.fill()
    }

    private func drawTime(){
        let text = NSAttributedString(string: buildDigitString(), attributes: defaultFontAttributes())
        if(!self.initialized){
          let textSize = text.size()
          initSizeAndPos(size:textSize)
        }
        let textRect = NSRect(x: clockPosition.x, y: clockPosition.y, width:clockSize.width, height: clockSize.height)
        text.draw(in: textRect)
    }
    private func initSizeAndPos(size:NSSize){
      self.clockSize = size
      self.clockPosition = NSPoint(x: bounds.midX - size.width/2, y:bounds.midY - size.height/2)
      self.targetPosition = getRandomPosition()
      self.initialized = true
    }
    
    override func animateOneFrame() {
        super.animateOneFrame()
        setNeedsDisplay(bounds)
    }
    // MARK: - Anim Helpers
    private func getRandomPosition() -> NSPoint {
        let margin: CGFloat = 10.0
        let x = CGFloat.random(in: margin...(bounds.size.width - clockSize.width - margin))
        let y = CGFloat.random(in: margin...(bounds.size.height - clockSize.height - margin))
        return NSPoint(x: x, y: y)
    }

    private func updatePosition() {
        let step = 0.75
        let dx = targetPosition.x - clockPosition.x
        let dy = targetPosition.y - clockPosition.y

        if abs(dx) > step || abs(dy) > step {
            let angle = atan2(dy, dx)
            let nx = clockPosition.x + CoreGraphics.cos(angle) * step
            let ny = clockPosition.y + CoreGraphics.sin(angle) * step
            clockPosition = NSPoint(x: nx, y: ny)
        } else {
            clockPosition = targetPosition
            // Set a new random target position
            targetPosition = getRandomPosition()
        }
    }

    // MARK: - String Building
    private func buildDigitString() -> String{
        let time = getTimeInts()
        var timeDigits:[Int] = []
        if(time[0]>9){
          timeDigits.append(time[0]/10)
          timeDigits.append(time[0] % 10)
        }else{
          timeDigits.append(0)
          timeDigits.append(time[0])
        }
        if(time[1]>9){
          timeDigits.append(time[1]/10)
          timeDigits.append(time[1] % 10)
        }else{
          timeDigits.append(0)
          timeDigits.append(time[1])
        }
        var digitString: String = ""
        for i in 0...digitHeight-1{
          var stringBuffer:String = ""
          for j in 0...timeDigits.count-1{
            stringBuffer+=getDigitLine(digit: timeDigits[j], row: i)
            if !(j==3){
              if(j==1){
                stringBuffer+=getColonRow(row:i)
              }else{
                  stringBuffer += " "
              }
            }else{
              stringBuffer += "\n"
            }
          }
          digitString += stringBuffer
        }
        return containerCompose(digits: digitString)
    }

    private func containerCompose(digits:String) -> String{
      let digitArray = digits.split(separator: "\n")
      var composedString = ""
      for i in 0...slicedContainer.count - 1{
        if(i > 4 && i < 10){
          composedString += slicedContainer[i].prefix(14)
          composedString += digitArray[i-5]
          if(i == 9){
            composedString += (am ? " am" : " pm")
            composedString += slicedContainer[i].suffix(12)
          }else{
            composedString += slicedContainer[i].suffix(15)
          }
        }else{
          if(i == 11){
            composedString += slicedContainer[i].prefix(24)
            composedString += getDateStr()
            composedString += slicedContainer[i].suffix(25)
          }else{
            composedString += slicedContainer[i]
          }
        }
        composedString += "\n"
      }
      return composedString
    }

    private func getDigitLine(digit:Int, row:Int) -> String{
      return String(slicedDigits[digit][row]) + "­" //invis char to align text
    }

    private func getTimeInts() -> Array<Int>{
        let requestedComponents: Set<Calendar.Component> = [
            .hour,
            .minute
        ]
        let timeComponents = userCalendar.dateComponents(requestedComponents, from: Date())
        if var hour = timeComponents.hour, let minute = timeComponents.minute {
          if(hour > 12){
            hour -= 12
            am = false
          }
          return [hour, minute]
        } else {
            // Handle the case where hour or minute is nil
            return [0, 0] // or any other default values
        }
    }

    private func getDateStr() -> String{
      let formatter = DateFormatter()
      formatter.dateFormat = "dd/MM/yyyy"
      return formatter.string(from: Date())
    }

    private func defaultFontAttributes() -> [NSAttributedString.Key : Any]{
        let paragraphStyle = NSMutableParagraphStyle()
        paragraphStyle.alignment = .center
        let font = NSFont(name: "Menlo", size:12)
        let fontAttributes = [
            NSAttributedString.Key.font: font as Any,
            NSAttributedString.Key.paragraphStyle: paragraphStyle,
            NSAttributedString.Key.foregroundColor: NSColor.white
        ]
        return fontAttributes
    }
}
