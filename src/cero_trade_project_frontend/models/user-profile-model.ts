import store from "@/store";

export class UserProfileModel {
  companyLogo: string;
  principalId: string;
  companyId: string;
  companyName: string;
  city: string;
  country: string;
  address: string;
  email: string;
  createdAt: string;
  updatedAt: string;

  static get(): UserProfileModel  {
    return store.state.profile;
  }
}
