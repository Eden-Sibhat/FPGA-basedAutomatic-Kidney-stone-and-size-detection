import os
os.environ["TF_CPP_MIN_LOG_LEVEL"] = "2"
import numpy as np
import cv2
from glob import glob
from tqdm import tqdm
import tensorflow as tf
from keras.utils import CustomObjectScope
from metrics import dice_loss, dice_coef, iou
from train import load_data, create_dir, tf_dataset
from PIL import Image

def process_image(image_path):
    # Load the image
    image = Image.open(image_path)
    H = 512
    W = 512
    np.random.seed(42)
    tf.random.set_seed(42)

    """ Loading model """
    with CustomObjectScope({'iou': iou, 'dice_coef': dice_coef, 'dice_loss': dice_loss}):
        model = tf.keras.models.load_model("ct/model.h5")

    """ Reading the image """

    ori_x = cv2.imread(image_path, cv2.IMREAD_COLOR)
    ori_x = cv2.resize(ori_x, (W, H))
    x = ori_x / 255.0
    x = x.astype(np.float32)
    x = np.expand_dims(x, axis=0)

    """ Predicting the mask """
    y_pred = model.predict(x)[0] > 0.5
    y_pred = y_pred.astype(np.int32)  # Convert to the same data type as ori_x

    """ Saving the predicted mask along with the image """
    save_image_path = "C:/Users/bekri/Downloads/ct_images/49.png"
    y_pred = np.concatenate([y_pred, y_pred, y_pred], axis=-1)
    y_pred = y_pred
    sep_line = np.ones((H, 10, 3)) * 255
    cat_image = np.concatenate([ori_x, sep_line,  sep_line, y_pred * 255, sep_line, ori_x * y_pred], axis=1)

    # result = cv2.addWeighted(ori_x, 0.7, y_pred.astype(np.uint8), 0.3, 0)  # Convert y_pred to uint8
    cv2.imwrite(save_image_path, cat_image)


    return ori_x * y_pred

process_image("C:\\Users\\bekri\\Downloads\\ct_images\\original_Image\\49.png")

