//
//  CameraInput.swift
//  ChatExample
//
//  Created by Mohannad on 12/25/20.
//  Copyright © 2020 MessageKit. All rights reserved.
//

import InputBarAccessoryView
import UIKit

// MARK: - CameraInputBarAccessoryViewDelegate

protocol CameraInputBarAccessoryViewDelegate: InputBarAccessoryViewDelegate {
  func inputBar(_ inputBar: InputBarAccessoryView, didPressSendButtonWith attachments: [AttachmentManager.Attachment])
}

extension CameraInputBarAccessoryViewDelegate {
  func inputBar(_: InputBarAccessoryView, didPressSendButtonWith _: [AttachmentManager.Attachment]) { }
}

// MARK: - CameraInputBarAccessoryView

class CameraInputBarAccessoryView: InputBarAccessoryView {
  // MARK: Lifecycle

  override init(frame: CGRect) {
    super.init(frame: frame)
    configure()
  }

  required init?(coder _: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }

  // MARK: Internal

  lazy var attachmentManager: AttachmentManager = { [unowned self] in
    let manager = AttachmentManager()
    manager.delegate = self
    return manager
  }()

    func configure() {
        inputTextView.placeholderTextColor = .init(hex: "#81838A")
        separatorLine.isHidden = true
        let items = [
            makeButton(named: "ic_camera").onTextViewDidChange { button, textView in
                button.isEnabled = textView.text.isEmpty
                }.onSelected {
                    $0.tintColor = .systemBlue
            },
            makeButton(named: "ic_camera").onTextViewDidChange { button, textView in
                button.isEnabled = textView.text.isEmpty
                }.onSelected {
                    $0.tintColor = .systemBlue
                },
            sendButton.onSelected {
                    $0.transform = CGAffineTransform(scaleX: 1.2, y: 1.2)
                }.onDeselected {
                    $0.transform = CGAffineTransform.identity
            }
        ]
        setStackViewItems(items, forStack: .right, animated: false)
        rightStackView.alignment = .center
        
        let itemsTop = [
            makeViewButton(named: "Outfits").onTextViewDidChange { button, textView in
                button.isEnabled = textView.text.isEmpty
                }.onSelected {
                    $0.tintColor = .systemBlue
            },
            makeViewButton(named: "Actions").onTextViewDidChange { button, textView in
                button.isEnabled = textView.text.isEmpty
                }.onSelected {
                    $0.tintColor = .systemBlue
            },
        ]
        setStackViewItems(itemsTop, forStack: .top, animated: false)
        topStackView.alignment = .center
        padding = UIEdgeInsets(top: 12, left: 16, bottom: 12, right: 16)
        topStackView.axis = .horizontal
    }
    private func makeButton(named: String) -> InputBarButtonItem {
        let inputBarButtonItem =   InputBarButtonItem()
            .configure {
                $0.spacing = .fixed(0)
                $0.image = UIImage(named: named)?.withRenderingMode(.alwaysTemplate)
                $0.setSize(CGSize(width: 24, height: 24), animated: false)
            }.onSelected {
                $0.tintColor = .systemBlue
            }.onDeselected {
                $0.tintColor = UIColor.lightGray
            }.onTouchUpInside { _ in
                print("Item Tapped")
        }
        inputBarButtonItem.inputBarAccessoryView?.shouldManageSendButtonEnabledState = false
        return inputBarButtonItem
    }
    
    private func makeViewButton(named: String) -> InputBarViewButton {
        let inputBarViewButton =  InputBarViewButton()
            .configure {
                $0.spacing = .fixed(0)
//                $0.image = UIImage(named: named)?.withRenderingMode(.alwaysTemplate)
//                $0.setSize(CGSize(width: 94, height: 32), animated: false)
            }.onSelected {
                $0.tintColor = .systemBlue
            }.onDeselected {
                $0.tintColor = UIColor.lightGray
            }.onTouchUpInside { _ in
                print("HungPT Item Tapped")
            }
        inputBarViewButton.customImageView.image =  UIImage(named: "ic_appstore")
        inputBarViewButton.customLabel.text =  named
        inputBarViewButton.contentView.backgroundColor = .red
        inputBarViewButton.contentView.layer.cornerRadius = 16
        inputBarViewButton.inputBarAccessoryView?.shouldManageSendButtonEnabledState = false
        return inputBarViewButton
    }
}

// MARK: UIImagePickerControllerDelegate, UINavigationControllerDelegate

extension CameraInputBarAccessoryView: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
  @objc
  func showImagePickerControllerActionSheet() {
    let photoLibraryAction = UIAlertAction(title: "Choose From Library", style: .default) { [weak self] _ in
      self?.showImagePickerController(sourceType: .photoLibrary)
    }

    let cameraAction = UIAlertAction(title: "Take From Camera", style: .default) { [weak self] _ in
      self?.showImagePickerController(sourceType: .camera)
    }

    let cancelAction = UIAlertAction(title: "Cancel", style: .default, handler: nil)

    AlertService.showAlert(
      style: .actionSheet,
      title: "Choose Your Image",
      message: nil,
      actions: [photoLibraryAction, cameraAction, cancelAction],
      completion: nil)
  }

  func showImagePickerController(sourceType: UIImagePickerController.SourceType) {
    let imgPicker = UIImagePickerController()
    imgPicker.delegate = self
    imgPicker.allowsEditing = true
    imgPicker.sourceType = sourceType
    imgPicker.presentationController?.delegate = self
    inputAccessoryView?.isHidden = true
    getRootViewController()?.present(imgPicker, animated: true, completion: nil)
  }

  func imagePickerController(
    _: UIImagePickerController,
    didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey: Any])
  {
    if let editedImage = info[UIImagePickerController.InfoKey.editedImage] as? UIImage {
      // self.sendImageMessage(photo: editedImage)
      inputPlugins.forEach { _ = $0.handleInput(of: editedImage) }
    }
    else if let originImage = info[UIImagePickerController.InfoKey.originalImage] as? UIImage {
      inputPlugins.forEach { _ = $0.handleInput(of: originImage) }
      // self.sendImageMessage(photo: originImage)
    }
    getRootViewController()?.dismiss(animated: true, completion: nil)
    inputAccessoryView?.isHidden = false
  }

  func imagePickerControllerDidCancel(_: UIImagePickerController) {
    getRootViewController()?.dismiss(animated: true, completion: nil)
    inputAccessoryView?.isHidden = false
  }

  func getRootViewController() -> UIViewController? {
    (UIApplication.shared.delegate as? AppDelegate)?.window?.rootViewController
  }
}

// MARK: AttachmentManagerDelegate

extension CameraInputBarAccessoryView: AttachmentManagerDelegate {
  // MARK: - AttachmentManagerDelegate

  func attachmentManager(_: AttachmentManager, shouldBecomeVisible: Bool) {
    setAttachmentManager(active: shouldBecomeVisible)
  }

  func attachmentManager(_ manager: AttachmentManager, didReloadTo _: [AttachmentManager.Attachment]) {
    sendButton.isEnabled = manager.attachments.count > 0
  }

  func attachmentManager(_ manager: AttachmentManager, didInsert _: AttachmentManager.Attachment, at _: Int) {
    sendButton.isEnabled = manager.attachments.count > 0
  }

  func attachmentManager(_ manager: AttachmentManager, didRemove _: AttachmentManager.Attachment, at _: Int) {
    sendButton.isEnabled = manager.attachments.count > 0
  }

  func attachmentManager(_: AttachmentManager, didSelectAddAttachmentAt _: Int) {
    showImagePickerControllerActionSheet()
  }

  // MARK: - AttachmentManagerDelegate Helper

  func setAttachmentManager(active: Bool) {
    let topStackView = topStackView
    if active, !topStackView.arrangedSubviews.contains(attachmentManager.attachmentView) {
      topStackView.insertArrangedSubview(attachmentManager.attachmentView, at: topStackView.arrangedSubviews.count)
      topStackView.layoutIfNeeded()
    } else if !active, topStackView.arrangedSubviews.contains(attachmentManager.attachmentView) {
      topStackView.removeArrangedSubview(attachmentManager.attachmentView)
      topStackView.layoutIfNeeded()
    }
  }
}

// MARK: UIAdaptivePresentationControllerDelegate

extension CameraInputBarAccessoryView: UIAdaptivePresentationControllerDelegate {
  // Swipe to dismiss image modal
  public func presentationControllerWillDismiss(_: UIPresentationController) {
    isHidden = false
  }
}
