import { Router } from "express";
import { authRequired, AuthRequest } from "../middleware/authRequired";
import { ok, fail } from "../utils/response";
import { upload } from "../modules/upload/upload-middleware";
import { uploadProfileImageToS3 } from "../modules/upload/s3-upload";

const router = Router();

router.post("/profile-image", authRequired, upload.single("image"), async (req: AuthRequest, res) => {
  try {
    if (!req.file) {
      return fail(res, 400, "image file is required");
    }

    const userId = req.user!.userId;
    const imageUrl = await uploadProfileImageToS3(userId, req.file);

    return ok(res, {
      imageUrl,
    });
  } catch (error: any) {
    return fail(res, 500, "failed to upload image");
  }
}
);

export default router;
