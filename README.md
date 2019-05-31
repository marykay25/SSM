# Deploy the DS Agent with SSM

> AWS Systems Manager Distributor is a feature that you can use to
> securely store and distribute software packages, such as software
> agents, in your accounts. Distributor integrates with existing Systems
> Manager features to simplify and scale the package distribution,
> installation, and update process.
>
> These instructions will walk you through how to use AWS Systems Manager
> Distributor to deploy the Trend Micro Deep Security Agent. We will
> assume you have a version of Deep Security Manager running and it is
> accessible to the instances running in AWS. If not, you can deploy the
> [Deep Security
> Manager](https://aws.amazon.com/marketplace/pp/B01AVYHVHO?qid=1557771737718&sr=0-2&ref_=srh_res_product_title)
> using our quick start on the AWS Marketplace.
>
> This will create an AWS IAM Instance Profile for the
> EC2 instances that we want to deploy the Deep Security Agent on. We
> will use a CloudFormation Template to create the instance profile,
> along with two SSM Parameters for the Deep Security Manager Hostname.
> The CFT must be deployed in the same region as your instances because
> the SSM Parameters and Distributor are regional entities.

Prerequisites:
==============

> **EC2 Instances** -- Instances you want to install the agent on. See
> Support Operating Systems for SSM.
>
> **AWS CLI** -- this is normally installed by default on most Windows
> and Amazon Linux AMIs
>
> **Systems Manager Agent** -- latest version -- This is installed by
> default on most Windows and Amazon Linux AMIs but you will need to
> upgrade to the latest version to ensure compatibility

Create the Instance Profile and SSM Parameters via CloudFormation
=================================================================

1.  Clone repo: <https://github.com/marykay25/SSM>

2.  Go to: <https://console.aws.amazon.com/cloudformation/>

> ![](images/image1.png)

3.  Click **Create Stack**.

4.  Click **Choose File**.

> ![](images/image2.png)

5.  Select the file **dsm\_ssm.template** from the repo.

> ![](images/image3.png)

6.  Click **Next**.

7.  Enter **DSMSSM** for the **Stack Name**.

8.  To fill out the template, reference the DSM deployment script by logging into your DSM, then clicking on **Support** at the top right and then select **Deployment Scripts**.
       - **DSMActivation**, enter the Activation URL from the DSM deployment script including the dsm prefix and trailing "/"
	   - **DSMManage**, enter in the DSM Manager URL from deployment script including the https prefix and port
	   - **TenantID**, Required only for DSaaS or Multi-Tenant Deployments, otherwise leave NON
       - **Token**, Required only for DSaaS or Multi-Tenant Deployments, otherwise leave NONE

> ![](images/image4.png)


9.  Click **Next**.

10. Enter **Name** under **Key** and **DSM SSM** under
    **Value**.![](images/image5.png)

11. Click **Next**.

> ![](images/image6.png)

12. Check the box next to: **I acknowledge that AWS CloudFormation might
    create IAM resources with custom names.**

> ![](images/image7.png)

13. Click **Create**.

> ![](images/image8.png)
>

14. Wait for the CloudFormation to complete.

Attach the Instance Profile to EC2 Instances
============================================

1.  Go to the EC2 Console.

2.  ![](images/image10.png) Select the instance you want to add to IAM Role.

3.  Select **EC2SSMInstanceProfile.**

    ![](images/image11.png)

4.  Click **Apply.**

5.  Repeat for any other additional instances.

Building the Distributor Package
================================

1.  Go to the S3 Console: <https://console.aws.amazon.com/s3/>

2.  Select a bucket or create a new one.

3.  Click the bucket name.

4.  Click **Create folder**. Name the folder
    **DSMDistributor.**![](images/image12.png)

5.  Click **Save.**

6.  Go into the folder **DSMDistributor.**

    ![](images/image13.png)

7.  Click **Upload**. Add the **manifest.json**,
    **TrendMicro\_Windows.zip**, and **TrendMicro\_Linux.zip.**

    ![](images/image14.png)

8.  Click **Upload.**

> ![](images/image15.png)

9.  Now click the **manifest.json** file and copy the link under
    **Object URL** up to the last '/'.

    ![](images/image16.png)

10. Go to System Manager:
    <https://console.aws.amazon.com/systems-manager/>

> ![](images/image17.png)

11. Click **Distributor.**

    ![](images/image18.png)

12. Click **Create Package.**

13. Enter a **Name.**

14. Enter a **Version name.**

15. Paste the URL from step 10 into **S3 Bucket Location.**

16. Select **Extract from package.**

> ![](images/image19.png)

17. Click **Create Package.**

> ![](images/image20.png)

18. Wait a minute.

19. On the left side, click
    **Distributor**.![](images/image21.png)

20. Click **TrendMicroDSMAgent** or the name you gave for the package.

> ![](images/image22.png)

21. Click **Install one time.**

> ![](images/image23.png)

22. Scroll down to **Targets.**

23. Select some **Target Instances** to install the agent onto.

-   The shortest collection interval is every 30 minutes, but can be
    longer. For more information:
    <https://docs.aws.amazon.com/systems-manager/latest/userguide/systems-manager-inventory.html>

> ![](images/image24.png)

24. Scroll to **Output options.**

25. Uncheck **Enable writing to an S3 bucket.**

> ![](images/image25.png)

26. Click **Run.**

> ![](images/image26.png)

27. After a few minutes, the command will succeed.

> ![](images/image27.png)

28. Now you can log into the Deep Security Manager console to see the
    new instances.

> ![](images/image28.png)
