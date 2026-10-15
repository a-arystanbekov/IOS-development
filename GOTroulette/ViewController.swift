import UIKit

struct Favorite {
    let imageName: String
    let title: String
    let details: String
}

class ViewController: UIViewController {

    @IBOutlet var imageView: UIImageView!
    @IBOutlet var titleLabel: UILabel!
    @IBOutlet var descriptionLabel: UILabel!

    private let favorites: [Favorite] = [
        Favorite(imageName: "john",
                 title: "Jon Snow",
                 details: "Ned Stark's bastard son, Lord Commander of the Night's Watch and King in the North."),
        Favorite(imageName: "daenerys",
                 title: "Daenerys Targaryen",
                 details: "Mother of Dragons, last of House Targaryen and claimant to the Iron Throne."),
        Favorite(imageName: "tyrion",
                 title: "Tyrion Lannister",
                 details: "A sharp-witted dwarf of House Lannister, master of words and Hand of the King."),
        Favorite(imageName: "Robb",
                 title: "Robb Stark",
                 details: "Ned's eldest son, the Young Wolf and King in the North, who led armies against the Lannisters."),
        Favorite(imageName: "cersei",
                 title: "Cersei Lannister",
                 details: "Queen of the Seven Kingdoms, ready to do anything for power and her children."),
        Favorite(imageName: "tormund",
                 title: "Tormund Giantsbane",
                 details: "A cheerful and fearless Wildling chieftain who became Jon's loyal ally."),
        Favorite(imageName: "Eddard",
                 title: "Eddard Stark",
                 details: "Lord of Winterfell and Hand of King Robert, a man of unshakable honor."),
        Favorite(imageName: "jaime",
                 title: "Jaime Lannister",
                 details: "The Kingslayer, finest swordsman of the Kingsguard and Cersei's twin brother."),
        Favorite(imageName: "jofrey",
                 title: "Joffrey Baratheon",
                 details: "The cruel young king, son of Cersei, who ruled the Seven Kingdoms."),
        Favorite(imageName: "stannis",
                 title: "Stannis Baratheon",
                 details: "A stern claimant to the Iron Throne, brother of King Robert and follower of the Red Priestess.")
    ]
    private var currentIndex: Int?
    private var isAnimating = false
    
    override func viewDidLoad() {
        super.viewDidLoad()

        imageView.contentMode = .scaleAspectFit
        imageView.layer.cornerRadius = 16
        imageView.clipsToBounds = true
        imageView.layer.borderWidth = 2
        imageView.layer.borderColor = UIColor(red: 0.85, green: 0.7, blue: 0.35, alpha: 1).cgColor

        titleLabel.textAlignment = .center
        titleLabel.font = UIFont(name: "Georgia-Bold", size: 24)
        titleLabel.textColor = UIColor(red: 0.85, green: 0.7, blue: 0.35, alpha: 1)
        titleLabel.adjustsFontSizeToFitWidth = true
        titleLabel.minimumScaleFactor = 0.6
        titleLabel.numberOfLines = 1

        descriptionLabel.textAlignment = .center
        descriptionLabel.numberOfLines = 0
        descriptionLabel.lineBreakMode = .byWordWrapping
        descriptionLabel.adjustsFontSizeToFitWidth = true
        descriptionLabel.minimumScaleFactor = 0.8
        descriptionLabel.font = UIFont(name: "Georgia", size: 16)
        descriptionLabel.textColor = .white

        for label in [titleLabel, descriptionLabel] {
            label?.layer.shadowColor = UIColor.black.cgColor
            label?.layer.shadowOpacity = 0.9
            label?.layer.shadowRadius = 4
            label?.layer.shadowOffset = CGSize(width: 0, height: 1)
        }

        show(at: 0, animated: false)
        imageView.transform = CGAffineTransform(scaleX: 0.85, y: 0.85)
    }
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        UIView.animate(withDuration: 0.6,
                       delay: 0,
                       usingSpringWithDamping: 0.7,
                       initialSpringVelocity: 0.6,
                       options: [],
                       animations: {
            self.imageView.transform = .identity
        })
    }

    @IBAction func buttonTapped(_ sender: UIButton) {
        guard !isAnimating else { return }

        // Анимация нажатия кнопки
        UIView.animate(withDuration: 0.1, animations: {
            sender.transform = CGAffineTransform(scaleX: 0.92, y: 0.92)
        }, completion: { _ in
            UIView.animate(withDuration: 0.25,
                           delay: 0,
                           usingSpringWithDamping: 0.5,
                           initialSpringVelocity: 0.8,
                           options: [],
                           animations: {
                sender.transform = .identity
            })
        })

        var candidates = Array(favorites.indices)
        if let current = currentIndex {
            candidates.removeAll { $0 == current }
        }
        guard let next = candidates.randomElement() else { return }
        show(at: next, animated: true)
    }

    private func show(at index: Int, animated: Bool) {
        guard favorites.indices.contains(index) else { return }
        let item = favorites[index]
        currentIndex = index

        guard animated else {
            apply(item)
            return
        }

        isAnimating = true
        let offset: CGFloat = 40

        // Старая карточка уходит
        UIView.animate(withDuration: 0.2, delay: 0, options: .curveEaseIn, animations: {
            self.imageView.alpha = 0
            self.imageView.transform = CGAffineTransform(translationX: -offset, y: 0).scaledBy(x: 0.9, y: 0.9)
            self.titleLabel.alpha = 0
            self.descriptionLabel.alpha = 0
        }, completion: { _ in
            // Подставляем новые данные, пока всё невидимо
            self.apply(item)
            self.imageView.transform = CGAffineTransform(translationX: offset, y: 0).scaledBy(x: 0.9, y: 0.9)

            // Новая карточка появляется
            UIView.animate(withDuration: 0.4,
                           delay: 0,
                           usingSpringWithDamping: 0.8,
                           initialSpringVelocity: 0.5,
                           options: [],
                           animations: {
                self.imageView.alpha = 1
                self.imageView.transform = .identity
                self.titleLabel.alpha = 1
                self.descriptionLabel.alpha = 1
            }, completion: { _ in
                self.isAnimating = false
            })
        })
    }

    private func apply(_ item: Favorite) {
        imageView.image = UIImage(named: item.imageName)
        titleLabel.text = item.title
        descriptionLabel.text = item.details
    }
}
