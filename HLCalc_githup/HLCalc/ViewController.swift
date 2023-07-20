//
//  ViewController.swift
//  HLCalc
//
//  Created by 黄龙 on 2023/7/3.
//

import UIKit
//import AVFoundation
//import AVFAudio
import AudioToolbox


class ViewController: UIViewController,UITextFieldDelegate,UITableViewDelegate, UITableViewDataSource {
    
    let calcField: UITextField = {
        let tmpField = UITextField()
        tmpField.text = ""
        tmpField.textAlignment = .right
        tmpField.textColor = .label
        tmpField.font = .systemFont(ofSize: 40)
        tmpField.adjustsFontSizeToFitWidth = true
        tmpField.minimumFontSize = 24
        return tmpField
    }()
    
    let resultLabel: UILabel = {
        let tmpLabel = UILabel()
        tmpLabel.textColor = .orange
        tmpLabel.font = .systemFont(ofSize: 30)
        tmpLabel.textAlignment = .right
        return tmpLabel
    }()
    
    let tableView:UITableView = {
        let table = UITableView()
        return table
    }()
    
  
    
//    let calcTextView: UITextView = {
//       let txtView = UITextView()
//        txtView.text = ""
//        txtView.textAlignment = .right
//        txtView.textColor = .label
//        txtView.font = .systemFont(ofSize: 30)
//        txtView.textContainer.maximumNumberOfLines = 1
//        txtView.backgroundColor = .cyan
//        txtView.alwaysBounceVertical = false
//        txtView.alwaysBounceHorizontal = true
//        txtView.keyboardType = .numberPad
//        txtView.textContainer.lineBreakMode = .byTruncatingHead
//        return txtView
//    }()
    
    var inputParam:String = "" //记录当前输入的数字段，判断数字是否正规
    var inputValueList:[String] = [] //输入的数字组
    var inputCalcList:[String] = [] //输入计算方法组
    var resultList:[String] = [] //历史计算记录
    var isTapedCalc:Bool = false //最后一次点击为=
//    var player: AVAudioPlayer?
    var alertView: UIView?
//    var needVoice:String? //voice文件名，不为空，则为播放音效
    
    var _soundID:SystemSoundID = 0
    
    var soundIDList:[SystemSoundID] = [0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0]
    var soundBtn:[UIButton] = []
    var soundIndex = 0
    let voiceName = ["Null","neon","bloop","bubble_pop","zoop_up","Gongfu"]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        self.view.backgroundColor = .systemBackground
        initUI()
        
        self.soundIndex = UserDefaults.standard.integer(forKey: "cala.voice.switch")
        initPlayer()
       
    }
    
    override func viewDidAppear(_ animated:Bool){
        super.viewDidAppear(animated)
        self.calcField.becomeFirstResponder()
        tableView.reloadData()
        
        self.setNeedsStatusBarAppearanceUpdate() //使prefersStatusBarHidden生效
    }
    
//控制顶部时间栏的显示与否
    override var prefersStatusBarHidden: Bool {
//prefersStatusBarHidden在viewDidLoad之后，viewDidAppear之前触发(此时不会生效)
//要使VC打开即生效，需在viewDidAppear里调用setNeedsStatusBarAppearanceUpdate刷新生效
        return true  //设置屏幕是否全屏，true=全屏 ,ViewLoad后会触发此，但首次启动后并不会生效
    }
    
    func initUI(){
        //上面放tableView存放每次计算结果
        //然后放一行当前计算等式
        //底部放计算按钮
        let perWidth = screen_W/4
        let perHeight = perWidth
        let bottomJG = UIDevice.ui_safeDistanceBottom()
        let bottomView = UIView(frame: CGRect(x: 0, y: screen_H-perHeight*5-bottomJG, width: screen_W, height: perHeight*5+bottomJG))
        view.addSubview(bottomView)
        bottomView.backgroundColor = .secondarySystemBackground
        
        view.addSubview(resultLabel)
        resultLabel.frame = CGRect(x: 0, y: bottomView.frame.minY-40, width: screen_W, height: 40)
        
        view.addSubview(calcField)
        calcField.frame = CGRect(x: 0, y: resultLabel.frame.minY-44, width: screen_W, height: 44)
        calcField.delegate = self
        
        let topbar = UIDevice.ui_statusBarHeight()+24
        view.addSubview(tableView)
        tableView.frame = CGRect(x: 0, y: topbar, width: screen_W, height: calcField.frame.minY-topbar)
        tableView.delegate = self
        tableView.dataSource = self
        tableView.register(TableViewCell.self, forCellReuseIdentifier: "TableViewCell")
        
        
        let moreBtn = UIButton(frame: CGRect(x: screen_W-15-42, y: topbar-40, width: 42, height: 42))
        view.addSubview(moreBtn)
        moreBtn.setImage(UIImage(named: "menu_more"), for: .normal)
        moreBtn.addActionWithBlock { sender in
//            let alert = UIAlertController(title: "更多操作", message: "", preferredStyle: .actionSheet)
//            let clearHistory = UIAlertAction(title: "清除计算记录", style: .default) { action in
//
//            }
//            let playAction = UIAlertAction(title: "播放音效", style: .default) { action in
//
//            }
//            alert.addAction(clearHistory)
//            alert.addAction(playAction)
//            self.present(alert, animated: true)
            self.showAlertView()
        }
        
        let arr = ["C","y√x","x^y","÷","7","8","9","×","4","5","6","-","1","2","3","+","←","0",".","="]
        
        var iLeft = 0.0
        var iTop = 0.0
        for j in 0 ..< 5{
            for i in 0 ..< 4{
                let view = UIView(frame: CGRect(x: iLeft, y: iTop, width: perWidth, height: perHeight))
                bottomView.addSubview(view)
                iLeft += perWidth
                let button = UIButton(frame: CGRect(x: 5, y: 5, width: perWidth-10, height: perHeight-10))
                view.addSubview(button)
                button.setTitle(arr[j*4+i], for: .normal)
                button.setTitleColor(.label, for: .normal)
                button.titleLabel?.font = .systemFont(ofSize: 28, weight: .bold)
                button.backgroundColor = .systemFill
                button.layer.cornerRadius = (perWidth-10)/2
                button.clipsToBounds = true
                button.tag = j*4+i+1
                if 3==i {
                    if 4==j{
                        button.backgroundColor = .orange
                    }else{
                        button.backgroundColor = .systemGray2
                    }
                }
                if 0==j{
                    button.backgroundColor = .systemGray2
                }else if(0==i && 4==j){
                    button.backgroundColor = .systemGray2
                }
                
                button.addActionWithBlock { [self] sender in
                    switch sender.tag {
                    case 1: //清除
                        self.doClearInput()
                    case 17: //回删除
                        self.doBackDelete()
                    case 5,6,7,9,10,11,13,14,15,18,19: //数字及.
                        let btnTitle = sender.titleLabel?.text
                        self.doInputDigital(digital: btnTitle!, isDot: 19 == sender.tag)
                    case 2,3,4,8,12,16: // + - x /
                        self.doInputCalcMethod(sender.tag)
                    case 20: //=
                        self.pressCalc()
                    default:
                        let str = self.calcField.text
                        self.calcField.text = str
                    }
                }
            }
            iTop += perHeight
            iLeft = 0
        }
        
    }
    
    func showAlertView(){
        self.removeAlertView(false)
        
        let backView = UIView(frame: CGRect(x: 0, y: 0, width: screen_W, height: screen_H))
        self.view.addSubview(backView)
        backView.backgroundColor = .systemBackground.withAlphaComponent(0)
        
        let contentView = UIView(frame: CGRect(x: 5, y: screen_H+20, width: screen_W-10, height: 485))
        backView.addSubview(contentView)
        contentView.backgroundColor = .systemBackground.withAlphaComponent(0.95)
        contentView.layer.cornerRadius = 10
        
        let titleLabel = UILabel(frame: CGRect(x: 0, y: 0, width: contentView.bounds.width, height: 50))
        contentView.addSubview(titleLabel)
        contentView.tag = 123
        titleLabel.text = "更多操作"
        titleLabel.textColor = .secondaryLabel
        titleLabel.font = .systemFont(ofSize: 14)
        titleLabel.textAlignment = .center
        
        let line_1 = CALayer()
        contentView.layer.addSublayer(line_1)
        line_1.frame = CGRect(x: 10, y: 60, width: contentView.bounds.width-20, height: 0.5)
        line_1.backgroundColor = UIColor.secondaryLabel.cgColor
        
        let button_Claer = UIButton(frame: CGRect(x: 0, y: 60, width: contentView.bounds.width, height: 60))
        contentView.addSubview(button_Claer)
        button_Claer.setTitle("清除计算记录", for: .normal)
        button_Claer.setTitleColor(.link, for: .normal)
        button_Claer.titleLabel?.font = .systemFont(ofSize: 17)
        button_Claer.addActionWithBlock { sender in
            self.resultList.removeAll()
            self.tableView.reloadData()
            self.removeAlertView(true)
        }
        
        let line_2 = CALayer()
        contentView.layer.addSublayer(line_2)
        line_2.frame = CGRect(x: 10, y: 2*60, width: contentView.bounds.width-20, height: 0.5)
        line_2.backgroundColor = UIColor.secondaryLabel.cgColor
        
        soundBtn.removeAll()
        var iBtnTop = 2*60
        for i in 0 ..< 6{
            let button_Voice = UIButton(frame: CGRect(x: 0, y: iBtnTop, width: Int(contentView.bounds.width), height: 60))
            contentView.addSubview(button_Voice)
            button_Voice.tag = 100+i
            button_Voice.setTitle("音效:\(voiceName[i])", for: .normal)
            button_Voice.setTitleColor(.link, for: .normal)
            button_Voice.titleLabel?.font = .systemFont(ofSize: 17)
            if i == self.soundIndex {
                button_Voice.setImage(UIImage(named: "gouxuan"), for: .normal)
                button_Voice.semanticContentAttribute = .forceRightToLeft
            }
            button_Voice.addActionWithBlock { sender in
                for perBtn in self.soundBtn{
                    perBtn.setImage(nil, for: .normal)
                }
                let index = sender.tag - 100
                UserDefaults.standard.setValue(index, forKey: "cala.voice.switch")
                UserDefaults.standard.synchronize()
                self.soundIndex = index
                
                if 0 == index{
                    self.freePlayer()
                }else{
                    self.initPlayer()
                }
                
                sender.setImage(UIImage(named: "gouxuan"), for: .normal)
                sender.semanticContentAttribute = .forceRightToLeft
                
                self.removeAlertView(true)
            }
            soundBtn.append(button_Voice)
            
            iBtnTop += 60
            if i != 5{
                let line_tmp = CALayer()
                contentView.layer.addSublayer(line_tmp)
                line_tmp.frame = CGRect(x: 10, y: CGFloat(iBtnTop), width: contentView.bounds.width-20, height: 0.5)
                line_tmp.backgroundColor = UIColor.tertiaryLabel.cgColor
            }
            
        }
        
        
        let tapBack = UITapGestureRecognizer(target: self, action: #selector(hideAlertView))
        backView.addGestureRecognizer(tapBack)
        
        alertView = backView
        UIView.animate(withDuration: 0.25, delay: 0, options:UIView.AnimationOptions.curveEaseInOut) {
            backView.backgroundColor = .systemBackground.withAlphaComponent(0.5)
            contentView.frame = CGRect(x: 5, y: screen_H - 485 - 34, width: screen_W-10, height: 485)
        }
    }
    
    @objc func hideAlertView(){
        removeAlertView(true)
    }
    
    func removeAlertView(_ animate:Bool){
        if alertView != nil{
            if animate {
                UIView.animate(withDuration: 0.25, delay: 0, options:UIView.AnimationOptions.curveEaseInOut) {
                    self.alertView?.backgroundColor = .systemBackground.withAlphaComponent(0)
                    if let contentView = self.alertView?.viewWithTag(123){
                        contentView.frame = CGRect(x: 5, y: screen_H+20, width: screen_W-10, height: 485)
                    }
                } completion: { finished in
                    for perView in self.alertView!.subviews{
                        perView.removeFromSuperview()
                    }
                    self.alertView?.removeFromSuperview()
                    self.alertView = nil
                    self.soundBtn.removeAll()
                }
            }else{
                for perView in self.alertView!.subviews{
                    perView.removeFromSuperview()
                }
                self.alertView?.removeFromSuperview()
                self.alertView = nil
                self.soundBtn.removeAll()
            }
        }
    }
    
    func getCurrentInputParam(){
        if self.inputValueList.count>0{
            if self.inputValueList.count>self.inputCalcList.count{
                self.inputParam = self.inputValueList[self.inputValueList.count-1]
            }else{
                self.inputParam = "" //计算方法后从新开始
            }
        }else{
            self.inputParam = ""
        }
    }
    
    func setCurrentInputParam() {
        if self.inputParam.count>0 && self.inputValueList.count == self.inputCalcList.count{
            //输入计算方法之后的数字输入
            self.inputValueList.append(self.inputParam)
            return
        }
        
        if self.inputValueList.count>0{
            self.inputValueList.removeLast()
        }
        
        if self.inputParam.count>0 && !self.inputParam.isEmpty{
            self.inputValueList.append(self.inputParam)
        }
        
        if 0==inputValueList.count{
            self.doClearInput()
        }
    }
    
    /*
     =计算
     */
    func pressCalc(){
        playNumVoice(11,3)
        
        if self.inputCalcList.count>0 && self.inputValueList.count>self.inputCalcList.count{
            let calcStr = self.calcField.text!
            self.calcResult()
            let str = String(format: "%@=%@", calcStr,self.resultLabel.text!)
            self.resultList.append(str)
            self.tableView.reloadData()
            
            
            self.inputParam = ""
            self.inputValueList.removeAll()
            self.inputCalcList.removeAll()
            isTapedCalc = true
            
            DispatchQueue.main.async {
                let indexpath = NSIndexPath(row: self.resultList.count-1, section: 0)
                self.tableView.scrollToRow(at: indexpath as IndexPath, at: .bottom, animated: true)
            }
        }
    }
    
    /*
     输入数字
     */
    func doInputDigital(digital:String,isDot:Bool){
        if isDot{
            playNumVoice(10,1)
        }else if let iNum = Int(digital) {
            playNumVoice(iNum,1)
        }
        
        if isTapedCalc{
            isTapedCalc = false
            self.inputValueList.removeAll()
            self.calcField.text = ""
            self.resultLabel.text = ""
            self.inputCalcList.removeAll()
        }
        
        self.getCurrentInputParam()
        
        if isDot{
            if 0==self.inputParam.count{
                //第1个输入.自动变成0.
                self.inputParam = "0."
                self.setCurrentInputParam()
                
                let str = self.calcField.text
                let result = String(format: "%@0.", str!)
                self.calcField.text = result
                return
            }
            else if self.inputParam.contains("."){
                return//不能有2个.
            }
        }
        self.inputParam = String(format: "%@%@", self.inputParam,digital)
        self.setCurrentInputParam()
        
        let str = self.calcField.text
        let result = String(format: "%@%@", str!,digital)
        self.calcField.text = result
    }
    
    /*
     输入+-x÷
     */
    func doInputCalcMethod(_ tag:Int){
        if isTapedCalc{
            isTapedCalc = false
            if let lastResult = self.resultLabel.text{
                self.inputValueList.removeAll()
                self.inputValueList.append(lastResult)
                self.calcField.text = lastResult
                self.resultLabel.text = ""
                self.inputCalcList.removeAll()
            }else{
                return
            }
        }
        var str = self.calcField.text
        if self.inputCalcList.count>=self.inputValueList.count{
            if self.inputValueList.count>0{
                self.inputCalcList.removeLast()
                str!.removeLast()//连着输入计算方法,即更新替换计算方法
            }else{
                return //没有数字之前输入计算方法，无效
            }
        }else{
            if self.inputValueList.count>1{
                self.calcResult() //新添加计算方法时，计算已有等式结果
            }
        }
        var sm = ""
        switch tag {
        case 2:
            sm = "√"
            playNumVoice(12,2)
        case 3:
            sm = "^"
            playNumVoice(13,2)
        case 4: //
            sm = "÷"
            playNumVoice(14,2)
        case 8:
            sm = "×"
            playNumVoice(15,2)
        case 12:
            sm = "-"
            playNumVoice(16,2)
        default: //+
            sm = "+"
            playNumVoice(17,2)
        }
        self.inputParam = ""
        self.inputCalcList.append(sm)
        let result = String(format: "%@%@", str!,sm)
        self.calcField.text = result
    }
    
    func calcResult(){
        if inputCalcList.count>0 && inputValueList.count>1{
            doCalc(Calc: inputCalcList, Value: inputValueList)
        }
    }
    
    func doCalc(Calc calcParam:[String],Value valueParam:[String]){
        var calcList = calcParam
        var valueList = valueParam
//优先幂和根号
        if calcList.count>0 && valueList.count>1 && calcList.contains("√") || calcList.contains("^"){
            for i in 0 ..< calcList.count{
                if valueList.count>i+1{
                    if "√" == calcList[i] {
                        let f1 = Float(valueList[i])
                        let f2 = Float(valueList[i+1])
                        let tmp = powf(f1!, 1/f2!)
                        if tmp > Float(Int64.max){
                            self.resultLabel.text = "算式有误：计算数据过大"
                            return
                        }
                        let tmpInt = CLongLong(tmp)
                        if tmp == Float(tmpInt){//无小数
                            let tmpResult = String(format: "%.0f", tmp)
                            calcList.remove(at: i)
                            valueList.remove(at: i+1)
                            valueList.remove(at: i)
                            valueList.insert(tmpResult, at: i)
                        }else{
                            let tmpResult = String(format: "%.2f", tmp)
                            calcList.remove(at: i)
                            valueList.remove(at: i+1)
                            valueList.remove(at: i)
                            valueList.insert(tmpResult, at: i)
                        }
                        break;
                    }else if "^" == calcList[i] {
                        let f1 = Float(valueList[i])
                        let f2 = Float(valueList[i+1])
                        let tmp = powf(f1!, f2!)
                        if tmp > Float(Int64.max){
                            self.resultLabel.text = "算式有误：计算数据过大"
                            return
                        }
                        let tmpInt = CLongLong(tmp)
                        if tmp == Float(tmpInt){//无小数
                            let tmpResult = String(format: "%.0f", tmp)
                            calcList.remove(at: i)
                            valueList.remove(at: i+1)
                            valueList.remove(at: i)
                            valueList.insert(tmpResult, at: i)
                        }else{
                            let tmpResult = String(format: "%.2f", tmp)
                            calcList.remove(at: i)
                            valueList.remove(at: i+1)
                            valueList.remove(at: i)
                            valueList.insert(tmpResult, at: i)
                        }
                        break;
                    }
                }else{
                    self.resultLabel.text = "算式有误：缺少计算项"
                    return
                }
            }
            
            if calcList.count>0 && valueList.count>1 && calcList.contains("√") || calcList.contains("^"){
                doCalc(Calc: calcList, Value: valueList) //递归
                return
            }
        }
        
//再算乘除
        if calcList.count>0 && valueList.count>1 && calcList.contains("×") || calcList.contains("÷"){
            for i in 0 ..< calcList.count{
//找到计算方法的前后2个数字
                if valueList.count>i+1{
                    if "×" == calcList[i] {
                        let f1 = Float(valueList[i])
                        let f2 = Float(valueList[i+1])
                        let tmp = f1! * f2!
                        if tmp > Float(Int64.max){
                            self.resultLabel.text = "算式有误：计算数据过大"
                            return
                        }
                        let tmpInt = CLongLong(tmp)
                        if tmp == Float(tmpInt){ //无小数
                            let tmpResult = String(format: "%.0f", tmp)
                            calcList.remove(at: i)
                            valueList.remove(at: i+1)
                            valueList.remove(at: i)
                            valueList.insert(tmpResult, at: i)
                        }else{
                            let tmpResult = String(format: "%.2f", tmp)
                            calcList.remove(at: i)
                            valueList.remove(at: i+1)
                            valueList.remove(at: i)
                            valueList.insert(tmpResult, at: i)
                        }
                        break;
                        
                    }else if "÷" == calcList[i] {
                        if "0" == valueList[i+1]{
                            NSLog("!!!不能除0")
                            self.resultLabel.text = "算式有误：不能除0"
                            return
                        }
                        let f1 = Float(valueList[i])
                        let f2 = Float(valueList[i+1])
                        let tmp = f1! / f2!
                        if tmp > Float(Int64.max){
                            self.resultLabel.text = "算式有误：计算数据过大"
                            return
                        }
                        let tmpInt = CLongLong(tmp)
                        if tmp == Float(tmpInt){ //无小数
                            let tmpResult = String(format: "%.0f", tmp)
                            calcList.remove(at: i)
                            valueList.remove(at: i+1)
                            valueList.remove(at: i)
                            valueList.insert(tmpResult, at: i)
                        }else{
                            let tmpResult = String(format: "%.2f", tmp)
                            calcList.remove(at: i)
                            valueList.remove(at: i+1)
                            valueList.remove(at: i)
                            valueList.insert(tmpResult, at: i)
                        }
                        break
                    }
                }else{
                    self.resultLabel.text = "算式有误：缺少计算项"
                    return
                }
            }
            
            if calcList.count>0 && valueList.count>1 && calcList.contains("×") || calcList.contains("÷"){
                doCalc(Calc: calcList, Value: valueList) //递归
                return
            }
        }
        
//最后只剩下+-
        if calcList.count>0 && valueList.count>1 && calcList.contains("+") || calcList.contains("-"){
            for i in 0 ..< calcList.count{
                if valueList.count>i+1{
                    if "+" == calcList[i] {
                        let f1 = Float(valueList[i])
                        let f2 = Float(valueList[i+1])
                        let tmp = f1! + f2!
                        if tmp > Float(Int64.max){
                            self.resultLabel.text = "算式有误：计算数据过大"
                            return
                        }
                        let tmpInt = CLongLong(tmp)
                        if tmp == Float(tmpInt){ //无小数
                            let tmpResult = String(format: "%.0f", tmp)
                            calcList.remove(at: i)
                            valueList.remove(at: i+1)
                            valueList.remove(at: i)
                            valueList.insert(tmpResult, at: i)
                        }else{
                            let tmpResult = String(format: "%.2f", tmp)
                            calcList.remove(at: i)
                            valueList.remove(at: i+1)
                            valueList.remove(at: i)
                            valueList.insert(tmpResult, at: i)
                        }
                        break
                    }else{
                        let f1 = Float(valueList[i])
                        let f2 = Float(valueList[i+1])
                        let tmp = f1! - f2!
                        if tmp > Float(Int64.max){
                            self.resultLabel.text = "算式有误：计算数据过大"
                            return
                        }
                        let tmpInt = CLongLong(tmp)
                        if tmp == Float(tmpInt){ //无小数
                            let tmpResult = String(format: "%.0f", tmp)
                            calcList.remove(at: i)
                            valueList.remove(at: i+1)
                            valueList.remove(at: i)
                            valueList.insert(tmpResult, at: i)
                        }else{
                            let tmpResult = String(format: "%.2f", tmp)
                            calcList.remove(at: i)
                            valueList.remove(at: i+1)
                            valueList.remove(at: i)
                            valueList.insert(tmpResult, at: i)
                        }
                        break
                    }
                }else{
                    self.resultLabel.text = "算式有误：缺少计算项"
                    return
                }
            }
            if calcList.count>0 && valueList.count>1 && calcList.contains("+") || calcList.contains("-"){
                doCalc(Calc: calcList, Value: valueList) //递归
                return
            }
        }
        self.resultLabel.text = valueList[0]
        self.calcField.text = valueList[0]
    }
    
    /*
   回删
    */
    func doBackDelete(){
        let generator = UIImpactFeedbackGenerator(style: .soft)
        generator.impactOccurred()
        
        var str = self.calcField.text
        if str!.count>0{
            str!.removeLast()
            if 0==str!.count{
                self.doClearInput()
                return
            }else{
                self.calcField.text = str!
            }
            
            if self.inputParam.count>0{
                self.inputParam.removeLast()
                self.setCurrentInputParam()
            }else{
    //清了一节数字，到了计算方法
                if self.inputCalcList.count>0{
                    self.inputCalcList.removeLast()
                    self.getCurrentInputParam()
                }else{
    //没有计算方法，说明只输入了一节数字，则表明已删除完毕
                    self.doClearInput()
                }
            }
        }else{
            self.doClearInput()
        }
        
        
    }
    
    /*
     清空
     */
    func doClearInput(){
        let generator = UIImpactFeedbackGenerator(style: .soft)
        generator.impactOccurred()
        
        self.calcField.text = ""
        self.resultLabel.text = ""
        self.inputParam = ""
        self.inputValueList.removeAll()
        self.inputCalcList.removeAll()
    }
    
    /*
     音效
     */
    func initPlayer() {
        if 5 == self.soundIndex {
            let arr = ["W00GRD01","W00GRD02","W00GRD03","W01GRD01","W01GRD02","W01GRD03",
                       "W00HIT01","W00HIT02","W00HIT03","W01HIT01","W01HIT02","W01HIT03",
                       "W00FIR01","W00FIR02","W00FIR03","W01FIR01","W01FIR02","W01FIR03"]
            for i in 0 ..< arr.count{
                let path_1 = Bundle.main.path(forResource: arr[i], ofType: "wav")
                let baseURL_1 = NSURL(fileURLWithPath: path_1!)
                AudioServicesCreateSystemSoundID(baseURL_1, &soundIDList[i])
            }
            
            AudioServicesDisposeSystemSoundID(_soundID)
            AudioServicesRemoveSystemSoundCompletion(_soundID)
            _soundID = 0
        }else if self.soundIndex > 0{
            let path = Bundle.main.path(forResource: voiceName[self.soundIndex], ofType: "wav") //无法识别caf
            let baseURL = NSURL(fileURLWithPath: path!)
            AudioServicesCreateSystemSoundID(baseURL, &_soundID)
            
            for i in 0 ..< soundIDList.count{
                AudioServicesDisposeSystemSoundID(soundIDList[i])
                AudioServicesRemoveSystemSoundCompletion(soundIDList[i])
                soundIDList[i] = 0
            }
        }
        
        
//        if player==nil {
//
//            guard let url = Bundle.main.url(forResource: "neon", withExtension: "wav") else{
//                return
//            }
//            do {
//                player = try AVAudioPlayer(contentsOf: url)
//                guard let _player = player else { return }
//                _player.prepareToPlay()
//            } catch let error as NSError {
//                print(error.description)
//            }
//        }
    }
    
    func playNumVoice(_ iNum:Int,_ iVibrate:Int){
        if (5 == self.soundIndex){
            if iNum < soundIDList.count{
                AudioServicesPlaySystemSound(soundIDList[iNum])
            }
        }else if (self.soundIndex > 0){
            AudioServicesPlaySystemSound(_soundID)
        }
        
        if iVibrate>0 && self.soundIndex != 5{
            if 1 == iVibrate{
                let generator = UIImpactFeedbackGenerator(style: .light)
                generator.impactOccurred()
            }else if 2 == iVibrate{
                let generator = UIImpactFeedbackGenerator(style: .medium)
                generator.impactOccurred()
            }else{
                let generator = UIImpactFeedbackGenerator(style: .heavy)
                generator.impactOccurred()
            }
        }
    }
    
    func freePlayer(){
        AudioServicesDisposeSystemSoundID(_soundID)
        AudioServicesRemoveSystemSoundCompletion(_soundID)
        _soundID = 0
        for i in 0 ..< soundIDList.count{
            AudioServicesDisposeSystemSoundID(soundIDList[i])
            AudioServicesRemoveSystemSoundCompletion(soundIDList[i])
            soundIDList[i] = 0
        }
//        if player != nil {
//            self.player?.stop()
//            self.player = nil
//        }
    }
    
    
    /*
     实现输入框，只显示光标，不显示键盘的效果
     */
    func textFieldShouldBeginEditing(_ textField:UITextField) -> Bool {
        if (textField.inputView == nil){
            textField.inputView = UIView(frame: CGRectZero)
        }
        return true
    }
    
    func textField(_ textField:UITextField,shouldChangeCharactersIn range:NSRange,replacementString string:String)->Bool{
        return false
    }

    
    /*
     tableView记录
     */
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.resultList.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        var cell = tableView.dequeueReusableCell(withIdentifier: "TableViewCell") as? TableViewCell
        if nil == cell{
            cell = UITableViewCell.init(style: .value1, reuseIdentifier: "TableViewCell") as? TableViewCell
        }
//        cell?.textLabel?.textAlignment = .right //修改无效
//        cell?.textLabel?.lineBreakMode = .byTruncatingHead
//        cell?.textLabel?.text = self.resultList[indexPath.row]
        cell!.showTitle(title: self.resultList[indexPath.row])
        return cell!
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 36
    }
    

}

