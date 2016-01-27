import pkg_resources
import imp

__file__ = pkg_resources.resource_filename(__name__, "cv2.so")
imp.load_dynamic(__name__, __file__)
