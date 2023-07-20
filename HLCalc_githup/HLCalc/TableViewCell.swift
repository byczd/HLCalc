//
//  TableViewCell.swift
//  HLCalc
//
//  Created by 黄龙 on 2023/7/18.
//

import UIKit

class TableViewCell: UITableViewCell {

    var titleLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        initUI()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func initUI(){
        titleLabel = UILabel(frame: CGRectMake(0, 0, frame.size.width, frame.size.height))
        titleLabel.textAlignment = .left
        titleLabel.lineBreakMode = .byTruncatingHead
        titleLabel.textColor =  .systemGray//.secondaryLabel
        titleLabel.font = .systemFont(ofSize: 20)
        titleLabel.adjustsFontSizeToFitWidth = true
        titleLabel.text = ""
        contentView.addSubview(titleLabel)
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        self.titleLabel.frame = self.contentView.bounds
    }

    func showTitle(title:String){
        self.titleLabel.text = title
    }
}
